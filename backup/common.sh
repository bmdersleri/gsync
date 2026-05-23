#!/usr/bin/env bash
set -euo pipefail

PROJECTS_DIR="${PROJECTS_DIR:-/home/haytek/projects}"
REMOTE_BASE="${REMOTE_BASE:-ismkirauto:backups/projects}"
TMP_DIR="${TMP_DIR:-${HOME}/.cache/project-backups}"
LOG_DIR="${LOG_DIR:-${HOME}/.local/state/project-backups}"

ensure_requirements() {
  mkdir -p "$TMP_DIR" "$LOG_DIR"

  if ! command -v git >/dev/null 2>&1; then
    echo "git bulunamadi. Once git kurun." >&2
    exit 1
  fi

  if ! command -v rclone >/dev/null 2>&1; then
    echo "rclone bulunamadi. Once rclone kurun." >&2
    exit 1
  fi

  if ! command -v zstd >/dev/null 2>&1; then
    echo "zstd bulunamadi. Once zstd kurun." >&2
    exit 1
  fi

  if [ ! -d "$PROJECTS_DIR" ]; then
    echo "Projects klasoru bulunamadi: $PROJECTS_DIR" >&2
    exit 1
  fi

  local remote_name
  remote_name="${REMOTE_BASE%%:*}"
  if ! rclone listremotes | grep -Fxq "${remote_name}:"; then
    echo "Rclone remote bulunamadi: ${remote_name}" >&2
    echo "Mevcut remote'lar:" >&2
    rclone listremotes >&2 || true
    exit 1
  fi
}

repo_root_from_input() {
  local input_path="${1:-$PWD}"

  if ! git -C "$input_path" rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "Git repo bulunamadi: $input_path" >&2
    exit 1
  fi

  git -C "$input_path" rev-parse --show-toplevel
}

make_archive_for_repo() {
  local repo_root="$1"
  local repo_parent repo_name archive_path

  repo_parent="$(dirname "$repo_root")"
  repo_name="$(basename "$repo_root")"
  archive_path="${TMP_DIR}/${repo_name}.tar.zst"

  tar \
    --zstd \
    --create \
    --file "$archive_path" \
    --directory "$repo_parent" \
    --exclude-vcs \
    --exclude='*/.venv' \
    --exclude='*/venv' \
    --exclude='*/node_modules' \
    --exclude='*/dist' \
    --exclude='*/build' \
    --exclude='*/.next' \
    --exclude='*/.nuxt' \
    --exclude='*/.cache' \
    --exclude='*/__pycache__' \
    --exclude='*/.pytest_cache' \
    --exclude='*/.mypy_cache' \
    --exclude='*/.tox' \
    --exclude='*/coverage' \
    --exclude='*/.DS_Store' \
    "$repo_name"

  printf '%s\n' "$archive_path"
}

upload_archive() {
  local archive_path="$1"
  local repo_name="$2"

  rclone copyto \
    --log-file "$LOG_DIR/rclone.log" \
    --log-level INFO \
    "$archive_path" \
    "${REMOTE_BASE}/${repo_name}.tar.zst"
}

prune_remote_archives() {
  local keep_file="$1"
  local remote_entry remote_name

  while IFS= read -r remote_entry; do
    [ -n "$remote_entry" ] || continue
    remote_name="$(basename "$remote_entry")"

    if ! grep -Fxq "$remote_name" "$keep_file"; then
      rclone deletefile \
        --log-file "$LOG_DIR/rclone.log" \
        --log-level INFO \
        "${REMOTE_BASE}/${remote_name}"
      printf 'Uzak arsiv silindi: %s/%s\n' "$REMOTE_BASE" "$remote_name"
    fi
  done < <(rclone lsf "$REMOTE_BASE" --max-depth 1)
}
