# Background pieces of the desktop. All of these run as systemd user services
# bound to graphical-session.target, which UWSM starts with Hyprland.

{ pkgs, ... }:

let
  wallpaper = import ../../wallpapers/catppuccin-nix.nix { inherit pkgs; };
  dpms = action: "hyprctl dispatch 'hl.dsp.dpms({ action = \"${action}\" })'";
in
{
  # Wallpaper daemon.
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "";
          path = "${wallpaper}";
          fit_mode = "cover";
        }
      ];
    };
  };

  # Lock screen. Layout and colours from the Catppuccin port; it shows the
  # image at ~/.config/background.
  programs.hyprlock.enable = true;
  xdg.configFile."background".source = wallpaper;

  # Idle: lock after 10 min, screens off after 11 min. No automatic suspend:
  # resume on NVIDIA is the most fragile part of this setup.
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = dpms "on";
      };
      listener = [
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 660;
          on-timeout = dpms "off";
          on-resume = dpms "on";
        }
      ];
    };
  };

  # Notifications + control center (Super+N, or the bell in Waybar).
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      control-center-margin-top = 8;
      control-center-margin-right = 8;
      control-center-margin-bottom = 8;
      notification-window-width = 400;
      timeout = 6;
      timeout-low = 3;
      fit-to-screen = true;
      widgets = [ "title" "dnd" "mpris" "notifications" ];
    };
  };

  # Volume OSD (driven by the media keys in hyprland.lua).
  services.swayosd.enable = true;

  # Clipboard history (Super+V).
  services.cliphist.enable = true;

  # GUI password prompts for polkit (e.g. mounting, GParted).
  services.hyprpolkitagent.enable = true;

  # Automount removable drives, with a tray icon.
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };

  # The network (nm-applet) and Bluetooth (blueman) tray applets are started
  # by their XDG autostart entries, installed system-wide in
  # modules/desktop.nix. Enabling the Home Manager services as well would only
  # start duplicates.

  # Night light: warmer screen from 20:00 to 07:00.
  services.hyprsunset = {
    enable = true;
    settings.profile = [
      {
        time = "7:00";
        identity = true;
      }
      {
        time = "20:00";
        temperature = 4000;
      }
    ];
  };
}
