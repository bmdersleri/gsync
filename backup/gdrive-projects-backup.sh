#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="/home/haytek/projects"
SOURCE_PARENT="$(dirname "$SOURCE_DIR")"
SOURCE_NAME="$(basename "$SOURCE_DIR")"
BACKUP_NAME="${BACKUP_NAME:-projects}"
REMOTE="${REMOTE:-ismkirauto:backups/${BACKUP_NAME}}"
TMP_DIR="${HOME}/.cache/project-backups"
LOG_DIR="${HOME}/.local/state/project-backups"
EXCLUDES_FILE="$(dirname "$0")/gdrive-projects-backup.exclude"
STAMP="$(date +%F_%H-%M-%S)"
ARCHIVE="${BACKUP_NAME}_${STAMP}.tar.zst"
KEEP_LAST="${KEEP_LAST:-30}"

mkdir -p "$TMP_DIR" "$LOG_DIR"

if ! command -v rclone >/dev/null 2>&1; then
  echo "rclone bulunamadi. Once rclone kurun." >&2
  exit 1
fi

if ! command -v zstd >/dev/null 2>&1; then
  echo "zstd bulunamadi. Once zstd kurun." >&2
  exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Kaynak klasor bulunamadi: $SOURCE_DIR" >&2
  exit 1
fi

REMOTE_NAME="${REMOTE%%:*}"
if ! rclone listremotes | grep -Fxq "${REMOTE_NAME}:"; then
  echo "Rclone remote bulunamadi: ${REMOTE_NAME}" >&2
  echo "Mevcut remote'lar:" >&2
  rclone listremotes >&2 || true
  exit 1
fi

tar \
  --zstd \
  --create \
  --file "$TMP_DIR/$ARCHIVE" \
  --directory "$SOURCE_PARENT" \
  --exclude-from "$EXCLUDES_FILE" \
  "$SOURCE_NAME"

rclone copy \
  --create-empty-src-dirs \
  --log-file "$LOG_DIR/rclone.log" \
  --log-level INFO \
  "$TMP_DIR/$ARCHIVE" \
  "$REMOTE"

find "$TMP_DIR" -maxdepth 1 -type f -name "${BACKUP_NAME}_*.tar.zst" -printf '%T@ %p\n' \
  | sort -nr \
  | awk -v keep="$KEEP_LAST" 'NR > keep {print $2}' \
  | while IFS= read -r old_file; do
      rm -f "$old_file"
    done
