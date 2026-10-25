# macOS Home Manager config (on top of home/common).

{ pkgs, ... }:

{
  imports = [
    ./aerospace.nix
    ./ssh.nix
  ];

  # macOS-only CLI programs. GUI apps: homebrew.casks in hosts/macbook/default.nix.
  # (Shared ones: home/common/default.nix.)
  home.packages = with pkgs; [
  ];

  # Target of system.defaults.screencapture.location.
  home.file."Pictures/Screenshots/.keep".text = "";
}
