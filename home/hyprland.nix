# Hyprland user config. The NixOS module (modules/desktop.nix) installs
# Hyprland and the portal; this only writes ~/.config/hypr/hyprland.lua and
# the UWSM session environment.

{ config, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    # Use the packages from programs.hyprland (NixOS module).
    package = null;
    portalPackage = null;
    # UWSM starts graphical-session.target itself.
    systemd.enable = false;
    configType = "lua";

    # catppuccin/nix adds `local colors = require('themes.catppuccin')` via settings.
    extraConfig = builtins.readFile ./hyprland.lua;
  };

  # Session environment, read by UWSM before Hyprland starts.
  # https://wiki.hypr.land/Useful-Utilities/Systemd-start/ (UWSM section)
  home.sessionVariables = {
    # NVIDIA on Wayland: VA-API video decoding and GLX vendor.
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
    # Qt apps: Wayland first, no client-side decorations.
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };
  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
  xdg.configFile."uwsm/env-hyprland".text = ''
    # Render on the RTX 4070 (the monitor is attached to it). The symlink is
    # created by a udev rule in modules/desktop.nix; /dev/dri/cardN is unstable.
    export AQ_DRM_DEVICES=/dev/dri/nvidia-gpu
  '';
}
