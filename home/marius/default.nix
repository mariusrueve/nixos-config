{ pkgs, lib, ... }:

{
  home.username = "marius";
  home.homeDirectory = "/home/marius";

  # Firefox configuration
  programs.firefox.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false; # sometimes helpful to disable check if it false-flags on VM/headless
    
    config = {
      modifier = "Mod4"; # Sets the "Windows" key as your main modifier
      terminal = "alacritty";
      fonts = {
        names = [ "JetBrains Mono Nerd Font" ];
        size = 11.0;
      };
      
      output = {
        "DP-3" = {
          # The mode matches your specific Iiyama ultrawide specs
          mode = "3440x1440@60Hz";
          pos = "0 0";
          scale = "1.25";
          # Set a solid background color for now so you don't see a black void
          bg = "#282c34 solid_color"; 
        };
      };
    };
  };

  # Add User-specific packages here
  home.packages = with pkgs; [
    thunderbird
    discord
    spotify
    vscode
    gh
    alacritty
    lazygit
    codex
    gemini-cli
    bitwarden-desktop
  ];

  # Basic Git config
  programs.git = {
    enable = true;
    
    userName = "mariusrueve";
    userEmail = "44000950+mariusrueve@users.noreply.github.com";

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      # You can add other git config items here, e.g.:
      # pull.rebase = true;
    };
  };

  home.sessionVariables = {
    # Fix for Electron apps on Wayland
    NIXOS_OZONE_WL = "1"; 
  };

  # This version allows Home Manager to be backwards compatible
  home.stateVersion = "25.05";
}
