#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_SCRIPT="${PROJECT_ROOT}/backup/gdrive-backup-repo.sh"

git config --global alias.gsync-push \
  "!f() { git push \"\$@\" && \"$BACKUP_SCRIPT\" \"\$(git rev-parse --show-toplevel)\"; }; f"

echo "Git alias kuruldu: git gsync-push"
