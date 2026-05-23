#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

ensure_requirements

REPO_ROOT="$(repo_root_from_input "${1:-$PWD}")"
REPO_NAME="$(basename "$REPO_ROOT")"
ARCHIVE_PATH="$(make_archive_for_repo "$REPO_ROOT")"

upload_archive "$ARCHIVE_PATH" "$REPO_NAME"

printf 'Yedek tamamlandi: %s -> %s/%s.tar.zst\n' \
  "$REPO_ROOT" \
  "$REMOTE_BASE" \
  "$REPO_NAME"
