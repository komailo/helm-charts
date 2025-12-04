#!/usr/bin/env bash

set -euo pipefail

# env vars chart-releaser expects (you probably already use these in CI)
export CR_OWNER="komailo"
export CR_GIT_REPO="helm-charts"
export CR_INDEX_PATH="index.yaml"
export CR_PAGES_BRANCH="gh-pages"

if [[ -z "${CR_TOKEN:-}" ]]; then
  echo "CR_TOKEN must be set so cr can talk to the GitHub API" >&2
  exit 1
fi

if ! command -v cr >/dev/null 2>&1; then
  echo "chart-releaser (cr) CLI is required" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required" >&2
  exit 1
fi

export GH_TOKEN="${GH_TOKEN:-$CR_TOKEN}"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

git clone "git@github.com:${CR_OWNER}/${CR_GIT_REPO}.git" "$WORKDIR/$CR_GIT_REPO"
cd "$WORKDIR/$CR_GIT_REPO"

git checkout "$CR_PAGES_BRANCH"

PKG_DIR=".cr-release-packages"
rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR"

echo "Downloading chart release assets into $PKG_DIR ..."
chart_urls="$(
  gh api \
    --paginate \
    "/repos/${CR_OWNER}/${CR_GIT_REPO}/releases" \
    --jq '.[] | .assets[] | select(.name | endswith(".tgz")) | .browser_download_url' \
    || true
)"

if [[ -z "$chart_urls" ]]; then
  echo "No .tgz assets found in releases" >&2
  exit 1
fi

while IFS= read -r url; do
  [[ -z "$url" ]] && continue
  file_name="$PKG_DIR/$(basename "$url")"
  echo "  -> $(basename "$file_name")"
  curl -sfL -H "Authorization: token $CR_TOKEN" -o "$file_name" "$url"
done <<< "$chart_urls"

cr index \
  --owner "$CR_OWNER" \
  --git-repo "$CR_GIT_REPO" \
  --index-path "$CR_INDEX_PATH" \
  --package-path "$PKG_DIR" \
  --pages-branch "$CR_PAGES_BRANCH" \
  --release-name-template "{{ .Name }}-{{ .Version }}"

git add "$CR_INDEX_PATH"
git commit -m "Rebuild Helm chart index after pruning old versions" || echo "No index changes to commit"
git push origin "$CR_PAGES_BRANCH"

echo "Updated index.yaml pushed to ${CR_OWNER}/${CR_GIT_REPO}:${CR_PAGES_BRANCH}"
