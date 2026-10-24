# Terminal, launcher and power menu. Colours come from catppuccin (home/theme.nix).

{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    settings = {
      window_padding_width = 8;
      # Slightly translucent; Hyprland blurs what's behind it.
      background_opacity = "0.92";
      scrollback_lines = 10000;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      # Static cursor: no trail animation, no blinking.
      cursor_trail = 0;
      cursor_blink_interval = 0;
    };
  };

  # App launcher (Alt+Space), also used for clipboard history and emoji.
  programs.rofi = {
    enable = true;
    package = pkgs.rofi; # rofi >= 2.0 is Wayland-native
    terminal = "kitty";
    font = "Inter 12";
    extraConfig = {
      show-icons = true;
      icon-theme = "Papirus-Dark";
      drun-display-format = "{name}";
      display-drun = "Apps";
      display-run = "Run";
      display-window = "Windows";
    };
  };

  # Power menu (Super+Shift+Escape, or the power button in Waybar).
  programs.wlogout = {
    enable = true;
    layout = [
      { label = "lock"; action = "loginctl lock-session"; text = "Lock"; keybind = "l"; }
      { label = "logout"; action = "uwsm stop"; text = "Logout"; keybind = "e"; }
      { label = "suspend"; action = "systemctl suspend"; text = "Suspend"; keybind = "u"; }
      { label = "reboot"; action = "systemctl reboot"; text = "Reboot"; keybind = "r"; }
      { label = "shutdown"; action = "systemctl poweroff"; text = "Shutdown"; keybind = "s"; }
    ];
  };

  # Screenshots from the Print binds (satty) land here.
  home.file."Pictures/Screenshots/.keep".text = "";
}
