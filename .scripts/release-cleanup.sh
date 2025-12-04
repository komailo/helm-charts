#!/usr/bin/env bash
set -euo pipefail

export GH_PAGER=
export PAGER=cat
export GIT_PAGER=cat

OWNER="komailo"        # change me
REPO="helm-charts"        # change me
KEEP=3                  # how many versions per chart to keep

# Get all releases as: tag_name created_at
releases=$(gh api \
  repos/"$OWNER"/"$REPO"/releases \
  --paginate \
  --jq '.[] | "\(.tag_name) \(.created_at)"')

# Sort by chart-name (derived from tag) and created_at DESC
# tag_name is like: foo-1.2.3  → chart=foo
echo "$releases" \
  | awk '{tag=$1; date=$2" "$3" "$4; sub(/\r$/,"",date); print tag" "date}' \
  | sort -k1,1 -k2,2r \
  | awk -v KEEP="$KEEP" '
    {
      tag = $1
      # chart name = everything before last "-"
      chart = tag
      sub(/-[^-]+$/, "", chart)

      key = chart

      count[key]++
      if (count[key] <= KEEP) {
        printf("KEEP %s (chart=%s)\n", tag, chart)
      } else {
        printf("DELETE %s (chart=%s)\n", tag, chart)
        system("gh release delete -y " tag)
      }
    }'


# clean up tags

# List all tags in the repo
tags=$(gh api repos/$OWNER/$REPO/git/refs/tags --jq '.[].ref | sub("refs/tags/"; "")')

# List all releases (their tags)
release_tags=$(gh api repos/$OWNER/$REPO/releases --paginate --jq '.[].tag_name')

# Compare: delete tags that are NOT releases anymore
for tag in $tags; do
  if ! echo "$release_tags" | grep -q "^$tag$"; then
    echo "Deleting orphan tag: $tag"
    gh api -X DELETE repos/$OWNER/$REPO/git/refs/tags/$tag
  else
    echo "Keeping tag (still has release): $tag"
  fi
done