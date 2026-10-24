# Linux desktop apps: launcher, power menu, browser, PDF viewer, default apps.
# Colours come from catppuccin. (kitty is shared: home/common/kitty.nix.)

{ pkgs, ... }:

let
  browser = "chromium-browser.desktop";
in
{
  # Default browser. Runs natively on Wayland via NIXOS_OZONE_WL
  # (modules/desktop.nix); catppuccin adds its Mocha theme extension.
  # Firefox (programs.firefox in configuration.nix) stays installed as a backup.
  programs.chromium.enable = true;

  # Keyboard-driven PDF viewer used by vimtex for LaTeX (SyncTeX jumps).
  # Double-clicked PDFs still open in Papers.
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      recolor = false;
    };
  };

  # Default apps. Home Manager now owns ~/.config/mimeapps.list, so anything
  # another program would write there must be declared here instead.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = browser;
      "application/xhtml+xml" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/unknown" = browser;
      # Claude Code login links (registered by Claude Code itself).
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
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
