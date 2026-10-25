#!/usr/bin/env bash
# One-time setup of the Nix environment on the uni server hessen (no root needed).
# Run it ON hessen, as mrueve, from a plain shell:
#   scp hosts/hessen/bootstrap.sh hessen:/local/mrueve/ && ssh hessen bash /local/mrueve/bootstrap.sh
#
# What it does (details: AGENTS.md, "hessen"):
#   1. nix-user-chroot binary -> /local/mrueve/bin, Nix store -> /local/mrueve/nix (mounted as /nix)
#   2. single-user Nix inside it, with HOME=/local/mrueve/home
#   3. clone this repo to /local/mrueve/nixos-config, home-manager switch .#mrueve@hessen
#   4. move the old NFS-home dotfiles/tools to ~/pre-nix-backup and write the
#      hook-only ~/.bashrc that enters the environment on interactive logins
# Safe to re-run: finished steps are skipped.
set -euo pipefail

BASE=/local/mrueve
NIXHOME=$BASE/home
CHROOT=$BASE/bin/nix-user-chroot
REPO=$BASE/nixos-config
NUC_VERSION=2.1.1
NFS_HOME=$(getent passwd "$USER" | cut -d: -f6)

[[ $(hostname -s) == hessen ]] || { echo "run this on hessen" >&2; exit 1; }
[[ -z ${IN_NIX_CHROOT:-} ]] || { echo "run this from a plain shell (touch $BASE/.nonix, reconnect)" >&2; exit 1; }

mkdir -p "$BASE/bin" "$BASE/nix" "$NIXHOME"

# 1. nix-user-chroot
if [[ ! -x $CHROOT ]]; then
  # Redirect instead of `curl -o`: hessen's AppArmor profile for /usr/bin/curl
  # only lets curl itself write to /tmp, not to /local or /work.
  curl -fL "https://github.com/nix-community/nix-user-chroot/releases/download/$NUC_VERSION/nix-user-chroot-bin-$NUC_VERSION-x86_64-unknown-linux-musl" \
    > "$CHROOT.part"
  chmod +x "$CHROOT.part"
  mv "$CHROOT.part" "$CHROOT"
fi

# The login session exports XDG_*_HOME pointing at the NFS home; drop them so
# Nix and Home Manager use $NIXHOME/.config etc. (home/hessen.nix: xdg.enable).
in_env() {
  env -u XDG_CONFIG_HOME -u XDG_DATA_HOME -u XDG_CACHE_HOME -u XDG_STATE_HOME \
    HOME="$NIXHOME" IN_NIX_CHROOT=1 "$CHROOT" "$BASE/nix" bash -c "$1"
}

# 2. Nix (single user, no daemon; profile setup comes from Home Manager)
if [[ ! -e $NIXHOME/.nix-profile/bin/nix ]]; then
  in_env 'curl -fL https://nixos.org/nix/install | sh -s -- --no-daemon --no-modify-profile'
fi

# 3. This repo + Home Manager
[[ -d $REPO/.git ]] || git clone https://github.com/mariusrueve/nixos-config.git "$REPO"
# NIX_CONFIG instead of a flag: the home-manager CLI runs its own `nix build`,
# and ~/.config/nix/nix.conf only exists after the first switch.
in_env ". ~/.nix-profile/etc/profile.d/nix.sh && cd $REPO && git pull --ff-only &&
  export NIX_CONFIG='experimental-features = nix-command flakes' &&
  nix run home-manager/release-26.05 -- switch -b hm-backup --flake .#mrueve@hessen"

# 4. NFS home: back up the old setup, then only the hook remains
if ! grep -q 'nixos-config: enter the Nix environment' "$NFS_HOME/.bashrc" 2>/dev/null; then
  backup=$NFS_HOME/pre-nix-backup
  mkdir -p "$backup"
  for f in .bashrc .bash_profile .profile .pixi .opencode .npm-global .cargo .rustup; do
    [[ -e $NFS_HOME/$f || -L $NFS_HOME/$f ]] && mv "$NFS_HOME/$f" "$backup/"
  done

  cat > "$NFS_HOME/.bashrc" <<'EOF'
# nixos-config: enter the Nix environment on hessen (touch /local/mrueve/.nonix to disable).
# Only interactive shells, so scp/rsync/cron/SGE jobs keep the stock environment.
# Everything else lives in /local/mrueve/home (Home Manager, home/hessen.nix).
if [[ $- == *i* && $(hostname -s) == hessen && -z $IN_NIX_CHROOT && ! -e /local/mrueve/.nonix \
      && -x /local/mrueve/bin/nix-user-chroot ]]; then
  export IN_NIX_CHROOT=1
  [[ $PWD == "$HOME" ]] && cd /local/mrueve
  exec env HOME=/local/mrueve/home /local/mrueve/bin/nix-user-chroot /local/mrueve/nix bash -l
fi
EOF
  echo '[ -f ~/.bashrc ] && . ~/.bashrc' > "$NFS_HOME/.bash_profile"
  echo "old dotfiles moved to $backup"
fi

echo "done: reconnect with 'ssh hessen'"
