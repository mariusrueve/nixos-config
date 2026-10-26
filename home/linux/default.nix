# Linux (Hyprland desktop) Home Manager config.

{ pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./services.nix
    ./apps.nix
    ./theme.nix
  ];

  # Linux-only programs. (Shared ones: home/common/default.nix.)
  home.packages = with pkgs; [
    spotify
    discord
    mattermost-desktop
    zotero
  ];
}
