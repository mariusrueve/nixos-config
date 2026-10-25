# Top bar. Colours (@base, @blue, @accent, ...) come from catppuccin/nix,
# which prepends the Mocha palette to `style`.

{ ... }:

let
  # Nerd Font icons, written as JSON escapes so the private-use glyphs
  # survive editors and copy/paste.
  glyph = s: builtins.fromJSON ''"${s}"'';
  i = builtins.mapAttrs (_: glyph) {
    circle = '''';
    dot = '''';
    alert = '''';
    clock = '''';
    music = '''';
    spotify = '''';
    pause = '''';
    mute = ''󰝟''; # md-volume_off
    volLow = '''';
    volMid = '''';
    volHigh = '''';
    ethernet = ''󰈀''; # md-ethernet
    wifi = '''';
    offline = '''';
    bluetooth = '''';
    bluetoothOff = ''󰂲''; # md-bluetooth_off
    cpu = '''';
    memory = ''󰍛''; # md-memory
    bell = '''';
    bellOff = '''';
  };
in
{
  programs.waybar = {
    enable = true;
    # Runs as a user service bound to graphical-session.target (started by UWSM).
    systemd.enable = true;

    settings.main = {
      layer = "top";
      position = "top";
      height = 34;
      margin-top = 6;
      margin-left = 8;
      margin-right = 8;
      spacing = 6;

      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [
        "mpris"
        "pulseaudio"
        "network"
        "bluetooth"
        "cpu"
        "memory"
        "tray"
        "custom/notifications"
        "custom/power"
      ];

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          default = i.circle;
          active = i.dot;
          urgent = i.alert;
        };
        persistent-workspaces."*" = 5;
        on-scroll-up = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e-1\" })'";
        on-scroll-down = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'";
      };

      "hyprland/window" = {
        max-length = 60;
        separate-outputs = true;
      };

      clock = {
        format = "${i.clock}  {:%a %d %b  %H:%M}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          weeks-pos = "left";
          on-scroll = 1;
          format = {
            months = "<span color='#f5e0dc'><b>{}</b></span>";
            weeks = "<span color='#94e2d5'><b>W{}</b></span>";
            weekdays = "<span color='#f9e2af'><b>{}</b></span>";
            today = "<span color='#f38ba8'><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
      };

      mpris = {
        format = "{player_icon} {title} – {artist}";
        format-paused = "{status_icon} <i>{title} – {artist}</i>";
        title-len = 30;
        artist-len = 20;
        player-icons.default = i.music;
        player-icons.spotify = i.spotify;
        status-icons.paused = i.pause;
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "${i.mute}  muted";
        format-icons.default = [ i.volLow i.volMid i.volHigh ];
        on-click = "uwsm app -- pavucontrol";
        on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        scroll-step = 5;
      };

      network = {
        format-ethernet = "${i.ethernet}  {ipaddr}";
        format-wifi = "${i.wifi}  {essid}";
        format-disconnected = "${i.offline}  offline";
        tooltip-format = "{ifname}: {ipaddr}/{cidr} via {gwaddr}";
        on-click = "uwsm app -- nm-connection-editor";
      };

      bluetooth = {
        format = i.bluetooth;
        format-disabled = i.bluetoothOff;
        format-connected = "${i.bluetooth} {num_connections}";
        tooltip-format-connected = "{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}";
        on-click = "uwsm app -- blueman-manager";
      };

      cpu = {
        format = "${i.cpu}  {usage}%";
        interval = 5;
      };

      memory = {
        format = "${i.memory}  {percentage}%";
        interval = 5;
        tooltip-format = "{used:0.1f} / {total:0.1f} GiB";
      };

      tray = {
        icon-size = 16;
        spacing = 8;
      };

      "custom/notifications" = {
        tooltip = false;
        format = "{icon}";
        format-icons = {
          notification = "${i.bell}<span foreground='#f38ba8'><sup>●</sup></span>";
          none = i.bell;
          dnd-notification = "${i.bellOff}<span foreground='#f38ba8'><sup>●</sup></span>";
          dnd-none = i.bellOff;
        };
        return-type = "json";
        exec = "swaync-client --subscribe-waybar";
        on-click = "swaync-client --toggle-panel --skip-wait";
        on-click-right = "swaync-client --toggle-dnd --skip-wait";
        escape = true;
      };

      "custom/power" = {
        format = "⏻";
        tooltip = false;
        on-click = "wlogout --protocol layer-shell";
      };
    };

    style = ''
      * {
        font-family: "Inter", "JetBrainsMono Nerd Font";
        font-size: 13px;
        min-height: 0;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background: transparent;
        color: @text;
      }

      /* Every module is a rounded "pill" on a translucent base. */
      #workspaces, #window, #clock, #mpris, #pulseaudio, #network, #bluetooth,
      #cpu, #memory, #tray, #custom-notifications, #custom-power {
        background: alpha(@base, 0.85);
        border-radius: 12px;
        padding: 0 12px;
        margin: 2px 0;
      }

      window#waybar.empty #window { background: transparent; }

      #workspaces { padding: 0 4px; }
      #workspaces button {
        color: @overlay1;
        padding: 0 6px;
        background: transparent;
        transition: all 0.2s ease;
      }
      #workspaces button.active { color: @accent; }
      #workspaces button.urgent { color: @red; }
      #workspaces button:hover { background: @surface0; border-radius: 10px; }

      #clock { color: @blue; font-weight: bold; }
      #mpris { color: @green; }
      #pulseaudio { color: @maroon; }
      #pulseaudio.muted { color: @overlay0; }
      #network { color: @teal; }
      #network.disconnected { color: @red; }
      #bluetooth { color: @sapphire; }
      #cpu { color: @peach; }
      #memory { color: @yellow; }
      #custom-notifications { color: @lavender; }
      #custom-power { color: @red; padding: 0 14px 0 12px; }

      tooltip {
        background: @mantle;
        border: 1px solid @surface1;
        border-radius: 10px;
      }
    '';
  };
}
