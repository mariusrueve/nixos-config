#!/usr/bin/env bash
# Nightly snapshot of /local/mrueve/home (hessen's local disk) to /work (NFS).
# Cron: 30 2 * * * /local/mrueve/scripts/hessen-backup.sh >> /work/stud2022/mrueve/backups/hessen/backup.log 2>&1
# Each day is a full tree; unchanged files are hardlinks to the previous
# snapshot (--link-dest), so only changes take space. Keeps the latest 7.
set -euo pipefail

SRC="/local/mrueve/home/"
BACKUP_ROOT="/work/stud2022/mrueve/backups/hessen"
SNAPSHOT_DIR="$BACKUP_ROOT/snapshots"
LATEST_LINK="$BACKUP_ROOT/latest"
TODAY="$(date +%F)"
DEST="$SNAPSHOT_DIR/$TODAY"

mkdir -p "$SNAPSHOT_DIR"

# A .partial from an interrupted run on an earlier day is useless now.
find "$SNAPSHOT_DIR" -mindepth 1 -maxdepth 1 -type d -name '*.partial' ! -name "$TODAY.partial" \
  -exec rm -rf {} +

if [[ -e "$DEST" ]]; then
  echo "Backup for $TODAY already exists: $DEST"
  exit 0
fi

if [[ -L "$LATEST_LINK" || -d "$LATEST_LINK" ]]; then
  LINK_DEST_ARG=(--link-dest="$LATEST_LINK")
else
  LINK_DEST_ARG=()
fi

# Excluded: caches, and Nix state (profiles are just links into /local/mrueve/nix,
# which is not backed up; it's rebuilt from the nixos-config repo).
# Dotfile symlinks into /nix/store are copied as symlinks (-a).
# Write to a .partial dir first, so an interrupted run never becomes "latest".
rsync -aH --delete \
  --exclude='/.cache/' \
  --exclude='/.local/state/nix/' \
  --exclude='/.local/state/home-manager/' \
  "${LINK_DEST_ARG[@]}" \
  "$SRC" \
  "$DEST.partial/"

mv "$DEST.partial" "$DEST"
ln -sfn "$DEST" "$LATEST_LINK"

# Keep only the latest 7 snapshot directories (leftover .partial dirs included)
find "$SNAPSHOT_DIR" -mindepth 1 -maxdepth 1 -type d \
  | sort \
  | head -n -7 \
  | xargs -r rm -rf

echo "$(date '+%F %T') Backup completed: $DEST"
