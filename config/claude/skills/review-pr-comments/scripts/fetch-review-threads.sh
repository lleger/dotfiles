#!/usr/bin/env bash
# Fetch all unresolved review threads on a PR via the GitHub GraphQL API,
# with pagination. Returns a JSON array of threads, each containing the
# ordered list of comments in that thread.
#
# Usage: fetch-review-threads.sh <owner> <repo> <pr_number>
#
# The first comment in `comments.nodes` is the root of the thread — use its
# `databaseId` when posting a reply via the REST replies endpoint.

set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <owner> <repo> <pr_number>" >&2
  exit 64
fi

owner=$1
repo=$2
number=$3

threads_query='query($owner:String!, $name:String!, $number:Int!, $cursor:String) {
  repository(owner:$owner, name:$name) {
    pullRequest(number:$number) {
      reviewThreads(first:100, after:$cursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id
          isResolved
          isCollapsed
          comments(first:100) {
            pageInfo { hasNextPage endCursor }
            nodes {
              databaseId
              author { login }
              body
              path
              line
              createdAt
            }
          }
        }
      }
    }
  }
}'

# Inner query for fetching the rest of a single thread's comments when it
# has more than 100 (rare, but happens on long-running review threads).
comments_query='query($id:ID!, $cursor:String!) {
  node(id:$id) {
    ... on PullRequestReviewThread {
      comments(first:100, after:$cursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          databaseId
          author { login }
          body
          path
          line
          createdAt
        }
      }
    }
  }
}'

threads='[]'
cursor=""
while :; do
  if [[ -z "$cursor" ]]; then
    page=$(gh api graphql -f query="$threads_query" -F owner="$owner" -F name="$repo" -F number="$number")
  else
    page=$(gh api graphql -f query="$threads_query" -F owner="$owner" -F name="$repo" -F number="$number" -f cursor="$cursor")
  fi

  page_threads=$(jq '.data.repository.pullRequest.reviewThreads.nodes' <<<"$page")
  threads=$(jq --argjson new "$page_threads" '. + $new' <<<"$threads")

  has_next=$(jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage' <<<"$page")
  [[ "$has_next" == "true" ]] || break
  cursor=$(jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor' <<<"$page")
done

# Drop resolved threads first so we don't waste calls paginating their comments.
unresolved=$(jq '[.[] | select(.isResolved == false)]' <<<"$threads")

# For any unresolved thread whose comments connection is paginated, fetch the
# rest with the inner query and append.
count=$(jq 'length' <<<"$unresolved")
for ((i=0; i<count; i++)); do
  has_more=$(jq -r ".[$i].comments.pageInfo.hasNextPage" <<<"$unresolved")
  [[ "$has_more" == "true" ]] || continue

  thread_id=$(jq -r ".[$i].id" <<<"$unresolved")
  inner_cursor=$(jq -r ".[$i].comments.pageInfo.endCursor" <<<"$unresolved")

  while :; do
    inner_page=$(gh api graphql -f query="$comments_query" -F id="$thread_id" -f cursor="$inner_cursor")
    new_nodes=$(jq '.data.node.comments.nodes' <<<"$inner_page")
    unresolved=$(jq --argjson new "$new_nodes" --argjson i "$i" '.[$i].comments.nodes += $new' <<<"$unresolved")

    has_more=$(jq -r '.data.node.comments.pageInfo.hasNextPage' <<<"$inner_page")
    [[ "$has_more" == "true" ]] || break
    inner_cursor=$(jq -r '.data.node.comments.pageInfo.endCursor' <<<"$inner_page")
  done
done

# Strip the inner pageInfo from output so the schema matches what the SKILL documents.
jq '[.[] | {id, isResolved, isCollapsed, comments: {nodes: .comments.nodes}}]' <<<"$unresolved"
