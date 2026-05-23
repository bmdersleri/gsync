#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK_SOURCE="${PROJECT_ROOT}/hooks/pre-push"
PROJECTS_DIR="${PROJECTS_DIR:-/home/haytek/projects}"

if [ ! -f "$HOOK_SOURCE" ]; then
  echo "Hook dosyasi bulunamadi: $HOOK_SOURCE" >&2
  exit 1
fi

installed=0
while IFS= read -r git_dir; do
  repo_root="$(dirname "$git_dir")"
  hook_target="${repo_root}/.git/hooks/pre-push"
  cp "$HOOK_SOURCE" "$hook_target"
  chmod +x "$hook_target"
  printf 'Hook kuruldu: %s\n' "$repo_root"
  installed=1
done < <(find "$PROJECTS_DIR" -mindepth 2 -maxdepth 2 -type d -name .git | sort)

if [ "$installed" -eq 0 ]; then
  echo "Hook kurulacak git repo bulunamadi: $PROJECTS_DIR" >&2
  exit 1
fi
