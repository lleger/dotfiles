#!/usr/bin/env bash
# Fetch all issue-level comments on a PR, paginated and flattened to a single
# JSON array.
#
# Usage: fetch-issue-comments.sh <owner> <repo> <pr_number>
#
# Why: `gh api --paginate` emits each page as a separate top-level JSON value
# (concatenated, not merged), which is hard for downstream parsers and easy to
# misuse. `--slurp` wraps the pages into a single array-of-pages; we flatten
# one level so callers get a plain array of comments and never have to think
# about pagination boundaries.

set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <owner> <repo> <pr_number>" >&2
  exit 64
fi

owner=$1
repo=$2
number=$3

gh api "repos/$owner/$repo/issues/$number/comments" --paginate --slurp | jq 'add // []'
