#!/usr/bin/env bash
# Post a batch of PR review-thread replies and/or issue-level comments via gh.
#
# Usage: post-replies.sh <owner> <repo> <pr_number> '<json_array>'
#
# The 4th argument is a JSON array passed as a single shell-quoted string.
# Keep it on one line so the whole bash invocation stays single-line — this
# matters because Claude Code's permission allowlist matches per-line, and a
# multi-line bash command prompts for approval even when the script path is
# allowlisted. JSON tolerates absent whitespace, so a long single-line array
# is fine.
#
# Each element of the array is one of:
#   {"type": "review", "root_id": <int>, "body": "<text>"}
#       Posts a reply to the review thread whose root comment ID is `root_id`.
#   {"type": "issue", "body": "<text>"}
#       Posts an issue-level comment on the PR.
#
# Each reply is posted with its own `gh api` POST so failures surface per-reply.
# Exits non-zero on the first failure.
#
# Bodies containing a single quote: escape as `'\''` inside the bash literal.

set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <owner> <repo> <pr_number> '<json_array>'" >&2
  exit 64
fi

owner=$1
repo=$2
pr=$3
json=$4

# Validate the JSON up front so a single bad entry doesn't leave half the
# replies posted. Checks: parses as JSON, is an array, each entry has a
# valid `type` and `body`, review entries have a numeric `root_id`.
if ! jq empty <<<"$json" 2>/dev/null; then
  echo "Replies input is not valid JSON" >&2
  exit 65
fi

if [[ "$(jq -r 'type' <<<"$json")" != "array" ]]; then
  echo "Replies input must be a JSON array (got $(jq -r 'type' <<<"$json"))" >&2
  exit 65
fi

errors=$(jq -r '
  to_entries[] |
  .key as $i | .value as $e |
  if ($e | type) != "object" then "[\($i)] not an object"
  elif ($e.type | type) != "string" then "[\($i)] missing or non-string `type`"
  elif ($e.type != "review" and $e.type != "issue") then "[\($i)] `type` must be \"review\" or \"issue\" (got \"\($e.type)\")"
  elif ($e.body | type) != "string" then "[\($i)] missing or non-string `body`"
  elif ($e.type == "review" and ($e.root_id | type) != "number") then "[\($i)] review entries require a numeric `root_id`"
  else empty
  end
' <<<"$json")

if [[ -n "$errors" ]]; then
  echo "Validation errors in replies JSON:" >&2
  echo "$errors" >&2
  exit 65
fi

count=$(jq 'length' <<<"$json")

for ((i=0; i<count; i++)); do
  entry=$(jq -c ".[$i]" <<<"$json")
  type=$(jq -r '.type' <<<"$entry")
  body=$(jq -r '.body' <<<"$entry")

  case "$type" in
    review)
      root_id=$(jq -r '.root_id' <<<"$entry")
      echo "[$((i+1))/$count] review reply on root #$root_id"
      gh api "repos/$owner/$repo/pulls/$pr/comments/$root_id/replies" -f body="$body" >/dev/null
      ;;
    issue)
      echo "[$((i+1))/$count] issue-level reply"
      gh api "repos/$owner/$repo/issues/$pr/comments" -f body="$body" >/dev/null
      ;;
    *)
      echo "Unknown reply type at index $i: $type" >&2
      exit 1
      ;;
  esac
done

echo "Posted $count replies."
