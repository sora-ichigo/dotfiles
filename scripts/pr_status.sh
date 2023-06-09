#!/bin/bash

repos=$(gh repo list wantedly --json nameWithOwner -q '.[].nameWithOwner')

for repo in $repos; do
  pr_count=$(gh pr list -R "$repo" --json number  -q 'length')

  if [ "$pr_count" -ge 1 ]; then
    echo "---------------------------------------------------"
    echo "PR Status for ${repo}:"
    gh pr status -R "${repo}"
    echo "---------------------------------------------------"
  fi
done

