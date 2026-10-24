# nix-darwin configuration for host "macbook" (Apple Silicon).
# Option docs: darwin-configuration.nix(5), https://nix-darwin.github.io/nix-darwin/manual/
#
# Rebuild: sudo darwin-rebuild switch --flake ~/nixos-config
# (The passwordless nixos-rebuild sudo rule exists only on the desktop.)

{ pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Nix itself is installed and managed by the Determinate Systems installer,
  # which writes its own /etc/nix/nix.conf (flakes on). nix-darwin must not
  # manage the daemon as well, or the two fight over it.
  nix.enable = false;

  networking.hostName = "macbook";
  networking.computerName = "MacBook";

  # Options that act on a user (defaults, Homebrew, ...) apply to this account.
  system.primaryUser = "marius";

  users.users.marius = {
    home = "/Users/marius";
    # Same shell as on the desktop. macOS' /bin/bash is 3.2; this is bash 5.
    shell = pkgs.bashInteractive;
  };
  # Registers Nix's bash in /etc/shells and sources the Nix environment in it.
  environment.shells = [ pkgs.bashInteractive ];
  programs.bash.enable = true;

  # Home Manager: same shared modules as the desktop, plus home/darwin/.
  home-manager.users.marius = import ../../home/macbook.nix;

  # Touch ID for sudo (also inside tmux, via pam_reattach).
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    inter
  ];

  # Active-window border, the AeroSpace counterpart of Hyprland's border
  # (Catppuccin Mocha blue → overlay0).
  services.jankyborders = {
    enable = true;
    style = "round";
    width = 3.0; # ≈ Hyprland border_size 2 at scale 1.5
    hidpi = true;
    active_color = "0xff89b4fa";
    inactive_color = "0x006c7086";
  };

  # GUI apps not packaged (or not working well) in nixpkgs on macOS.
  # Homebrew itself must be installed once by hand (https://brew.sh).
  # cleanup = "zap": anything not listed here gets removed on rebuild.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    casks = [
      "raycast" # launcher (Cmd+Space), clipboard history, emoji picker
      "google-chrome" # default browser (the chromium cask is unsigned)
      "firefox"
      "spotify"
      "discord"
      "skim" # PDF viewer with SyncTeX for vimtex
    ];
  };

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false; # key repeat instead of the accent popup (hjkl in nvim)
      AppleShowAllExtensions = true;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      # AeroSpace hides windows off-screen; this keeps them from animating.
      NSAutomaticWindowAnimationsEnabled = false;
    };
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false; # keep macOS Spaces in a fixed order
      expose-group-apps = true; # Mission Control groups windows per app (AeroSpace docs)
      tilesize = 48;
    };
    finder = {
      AppleShowAllFiles = true;
      ShowPathbar = true;
      FXPreferredViewStyle = "Nlsv"; # list view
      FXEnableExtensionChangeWarning = false;
    };
    # "Displays have separate Spaces" off: AeroSpace handles monitors itself.
    spaces.spans-displays = true;
    trackpad.Clicking = true; # tap to click
    screencapture.location = "~/Pictures/Screenshots";
  };

  # Remap Caps Lock to Escape (handy in nvim; matches nothing on the desktop, so off).
  # system.keyboard = { enableKeyMapping = true; remapCapsLockToEscape = true; };

  # nix-darwin's equivalent of system.stateVersion: never bump on upgrades.
  system.stateVersion = 7;
}
