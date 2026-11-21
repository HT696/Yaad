#!/usr/bin/env bash
# Publishes www/ (including the generated data) to the gh-pages branch.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [ -f "$ROOT/.github/workflows/pages.yml" ]; then
  echo "Branch deployment is disabled when the Pages workflow is present." >&2
  exit 1
fi
REMOTE="$(git -C "$ROOT" remote get-url origin)"
[ -f "$ROOT/www/data/meta.json" ] || { echo "www/data missing: run npm run build:data first"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp -r "$ROOT/www/." "$TMP/"
touch "$TMP/.nojekyll"
cd "$TMP"
git init -q -b gh-pages
git add -A
git -c user.name="$(git -C "$ROOT" config user.name)" -c user.email="$(git -C "$ROOT" config user.email)" \
  commit -q -m "Deploy web app ($(git -C "$ROOT" rev-parse --short HEAD))"
git push -f "$REMOTE" gh-pages
echo "Deployed to gh-pages"
