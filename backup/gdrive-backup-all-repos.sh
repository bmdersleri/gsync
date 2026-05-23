#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

ensure_requirements

found_repo=0
keep_file="$(mktemp)"
trap 'rm -f "$keep_file"' EXIT

while IFS= read -r git_dir; do
  found_repo=1
  repo_root="$(dirname "$git_dir")"
  repo_name="$(basename "$repo_root")"
  archive_path="$(make_archive_for_repo "$repo_root")"
  upload_archive "$archive_path" "$repo_name"
  printf '%s\n' "${repo_name}.tar.zst" >> "$keep_file"
  printf 'Yedek tamamlandi: %s -> %s/%s.tar.zst\n' \
    "$repo_root" \
    "$REMOTE_BASE" \
    "$repo_name"
done < <(find "$PROJECTS_DIR" -mindepth 2 -maxdepth 2 -type d -name .git | sort)

if [ "$found_repo" -eq 0 ]; then
  echo "Yedeklenecek git repo bulunamadi: $PROJECTS_DIR" >&2
  exit 1
fi

prune_remote_archives "$keep_file"
