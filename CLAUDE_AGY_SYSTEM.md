# gdrive-sync — Project Context

Bash automation that archives Git repos under `~/projects/` with zstd compression
and uploads them to Google Drive via rclone. Runs as a systemd user service/timer.

## Structure
- `backup/gdrive-backup-repo.sh` — archive + upload a single repo
- `backup/gdrive-backup-all-repos.sh` — loop over all repos
- `backup/gdrive-projects-backup.service` + `.timer` — systemd units
- `hooks/pre-push` — git pre-push hook (optional per-repo)
- `install/install-git-alias.sh` — installs `git gsync-push` alias
- `install/install-pre-push-hooks.sh` — installs pre-push hooks into existing repos

## Hard constraints
- Bash only. No Python, no external deps beyond `rclone` and `zstd`.
- Scripts must pass `bash -n` (syntax check) and `shellcheck`.
- Never modify systemd unit files without explicit instruction.
- Excluded dirs (never backed up): `.git`, `.venv`, `node_modules`, `dist`,
  `build`, `__pycache__`, `.pytest_cache`, `.mypy_cache`, `.next`, `.nuxt`.

## Delegation rules (when invoked via agykit do-escalate)
- Follow the given plan exactly. No scope creep.
- Never delete or weaken existing checks/validations.
- Never run git commands. Leave changes in working tree.
- Only edit files in: `backup/`, `hooks/`, `install/`
