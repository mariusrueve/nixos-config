# Terminal, identical on the desktop and the MacBook. Colours from catppuccin.

{ lib, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    # macOS: the official app comes from the Homebrew cask (hosts/macbook). The
    # nixpkgs kitty.app's main executable is a wrapper that execs .kitty-wrapped,
    # which leaves LaunchServices with a PID-less kitty entry, so AeroSpace never
    # manages its windows. Home Manager then only writes the config.
    package = lib.mkIf pkgs.stdenv.isDarwin null;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = if pkgs.stdenv.isDarwin then 13 else 11; # Retina vs 4K@1.5x
    };
    settings = {
      window_padding_width = 8;
      # Slightly translucent; Hyprland / macOS blur what's behind it.
      background_opacity = "0.92";
      scrollback_lines = 10000;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      # Static cursor: no trail animation, no blinking.
      cursor_trail = 0;
      cursor_blink_interval = 0;
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      # Option is the window-manager key (AeroSpace); don't let kitty eat it.
      macos_option_as_alt = "no";
      macos_quit_when_last_window_closed = true;
      background_blur = 20;
    };
  };
}
