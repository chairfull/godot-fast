#!/usr/bin/env bash
# Local reproduction of the CI build: clone Godot at the pinned base SHA,
# cherry-pick everything in cherry-picks.txt, build the Linux editor.
set -euo pipefail
cd "$(dirname "$0")"

BASE_SHA="$(grep '^# Pinned base' cherry-picks.txt | grep -o '[0-9a-f]\{40\}')"

if [ ! -d godot ]; then
  git init godot && cd godot
  git remote add origin https://github.com/godotengine/godot.git
  git fetch --depth 1 origin "$BASE_SHA"
  git checkout FETCH_HEAD
  cd ..
fi

cd godot
git config user.email "zlf-godot-editor@local" || true
git config user.name "zlf-godot-editor" || true
grep -v '^#' ../cherry-picks.txt | grep -v '^$' | while read -r pr sha rest; do
  if git merge-base --is-ancestor "$sha" HEAD 2>/dev/null; then
    echo "== $sha (PR #$pr) already applied, skipping =="
  else
    echo "== cherry-picking $sha (PR #$pr) =="
    git fetch --depth 2 origin "$sha"
    git cherry-pick "$sha"
  fi
done

scons platform=linuxbsd target=editor -j"$(nproc)"
echo "Built: $(pwd)/bin/godot.linuxbsd.editor.x86_64"
