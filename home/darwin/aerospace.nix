# AeroSpace: i3-like tiling on macOS, with keybinds mirroring home/linux/hyprland.lua.
# Option (alt) sits where Super is on the desktop keyboard, Cmd where Alt is,
# so the same fingers do the same thing on both machines.
# Docs: https://nikitabobko.github.io/AeroSpace/guide
#
# Differences from Hyprland: the layout is an i3-style tree rather than dwindle
# (new windows split the focused container), there is no toggleable scratchpad
# (Option+S is a plain workspace "S"), and notifications/colour picker have no binds.

{ config, ... }:

let
  kitty = "${config.programs.kitty.package}/Applications/kitty.app";

  # Option+H/J/K/L focus, +Shift move, +Ctrl resize (same as on the desktop).
  directions = {
    h = "left";
    j = "down";
    k = "up";
    l = "right";
  };
  resizeSteps = {
    h = "width -50";
    j = "height +50";
    k = "height -50";
    l = "width +50";
  };
  dirBinds =
    builtins.foldl' (acc: k:
      acc
      // {
        "alt-${k}" = "focus ${directions.${k}}";
        "alt-shift-${k}" = "move ${directions.${k}}";
        "alt-ctrl-${k}" = "resize ${resizeSteps.${k}}";
      }) { } (builtins.attrNames directions)
    // {
      alt-left = "focus left";
      alt-down = "focus down";
      alt-up = "focus up";
      alt-right = "focus right";
      alt-shift-left = "move left";
      alt-shift-down = "move down";
      alt-shift-up = "move up";
      alt-shift-right = "move right";
    };

  # Option+N workspace, +Shift move window and follow, +Cmd move silently
  # (desktop: Super+Alt+N).
  workspaces = map toString [ 1 2 3 4 5 6 7 8 9 ];
  workspaceBinds = builtins.foldl' (acc: n:
    acc
    // {
      "alt-${n}" = "workspace ${n}";
      "alt-shift-${n}" = [ "move-node-to-workspace ${n}" "workspace ${n}" ];
      "alt-cmd-${n}" = "move-node-to-workspace ${n}";
    }) { } workspaces;
in
{
  programs.aerospace = {
    enable = true;
    # Started by a Home Manager launchd agent (instead of AeroSpace's own
    # start-at-login). First run: allow it under Privacy & Security → Accessibility.
    launchd.enable = true;

    settings = {
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      # Mouse follows focus when switching monitors.
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      # Same spacing as Hyprland (gaps_in 4 per side = 8 between windows, gaps_out 8).
      gaps = {
        inner.horizontal = 8;
        inner.vertical = 8;
        outer.left = 8;
        outer.right = 8;
        outer.top = 8;
        outer.bottom = 8;
      };

      mode.main.binding =
        dirBinds
        // workspaceBinds
        // {
          # Apps
          alt-enter = "exec-and-forget open -n ${kitty}";
          alt-e = "exec-and-forget open ~";
          alt-b = "exec-and-forget open -a 'Google Chrome'";
          # Raycast stands in for cliphist and rofimoji (same keys as the desktop).
          alt-v = "exec-and-forget open raycast://extensions/raycast/clipboard-history/clipboard-history";
          alt-period = "exec-and-forget open raycast://extensions/raycast/emoji-symbols/search-emoji-symbols";
          # Lock: turning the display off locks (with "require password immediately").
          alt-esc = "exec-and-forget pmset displaysleepnow";

          # Windows
          alt-q = "close";
          alt-f = "fullscreen";
          alt-m = "macos-native-fullscreen";
          alt-t = "layout floating tiling";
          alt-o = "layout tiles horizontal vertical"; # like dwindle's togglesplit
          alt-comma = "layout accordion horizontal vertical"; # stacked, handy on the small screen
          alt-tab = "workspace-back-and-forth";

          # "Scratchpad" workspace
          alt-s = "workspace S";
          alt-shift-s = "move-node-to-workspace S";

          # Option+Shift+; → service mode (r: reset layout, esc: reload config)
          alt-shift-semicolon = "mode service";
        };

      mode.service.binding = {
        esc = [ "reload-config" "mode main" ];
        r = [ "flatten-workspace-tree" "mode main" ];
        f = [ "layout floating tiling" "mode main" ];
        backspace = [ "close-all-windows-but-current" "mode main" ];
      };

      # Dialog-like apps float, as with the Hyprland window rules.
      on-window-detected = [
        {
          "if".app-id = "com.apple.systempreferences";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.calculator";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.ActivityMonitor";
          run = "layout floating";
        }
      ];
    };
  };
}
