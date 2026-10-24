# Hourly btrfs snapshots of /home with snapper. NixOS generations cover the
# system; these cover user data (accidental deletes/overwrites). They live on
# the same disk, so they are NOT a backup against disk failure.
#
# Requires the /home/.snapshots subvolume (created once by hand:
# `sudo btrfs subvolume create /home/.snapshots`).
# Browse/restore: `snapper -c home list`, files under
# /home/.snapshots/<N>/snapshot/, or the btrfs-assistant GUI.

{ pkgs, ... }:

{
  services.snapper.configs.home = {
    SUBVOLUME = "/home";
    # Lets marius list/compare/delete snapshots without sudo.
    ALLOW_USERS = [ "marius" ];
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 24;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 4;
    TIMELINE_LIMIT_MONTHLY = 0;
    TIMELINE_LIMIT_YEARLY = 0;
  };

  environment.systemPackages = [ pkgs.btrfs-assistant ];
}
