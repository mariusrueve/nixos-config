-- Hyprland config (Lua, Hyprland >= 0.55). Appended by home/linux/hyprland.nix to the
-- generated ~/.config/hypr/hyprland.lua, after `local colors = require(...)`
-- (the Catppuccin Mocha palette: colors.blue = "rgb(89b4fa)", colors.blueAlpha = "89b4fa", ...).
-- Reference: https://wiki.hypr.land/Configuring/Start/
-- Environment variables are NOT set here; UWSM reads them from ~/.config/uwsm/env*.

------------------
---- MONITORS ----
------------------

-- 4K on the RTX 4070, max refresh rate, 1.5x scale (feels like 2560x1440).
hl.monitor({ output = "DP-4", mode = "highres@highrr", position = "auto", scale = 1.5 })
-- Anything else that gets plugged in.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- Let XWayland apps render at native resolution instead of being upscaled blurrily.
hl.config({ xwayland = { force_zero_scaling = true } })

---------------------
---- MY PROGRAMS ----
---------------------

-- `uwsm app --` runs each app in its own systemd scope (clean logout, per-app logs).
local function app(cmd) return "uwsm app -- " .. cmd end

local terminal    = app("kitty")
local fileManager = app("nautilus --new-window")
local browser     = app("chromium") -- Firefox stays installed as a backup
local menu        = "rofi -show drun -run-command 'uwsm app -- {cmd}'"

-----------------------
---- LOOK AND FEEL ----
-----------------------

local function rgba(hex, alpha) return "rgba(" .. hex .. alpha .. ")" end

hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 8,
        border_size = 2,
        col = {
            active_border   = { colors = { rgba(colors.blueAlpha, "ee"), rgba(colors.mauveAlpha, "ee") }, angle = 45 },
            inactive_border = rgba(colors.surface0Alpha, "aa"),
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = rgba(colors.crustAlpha, "99"),
        },

        blur = {
            enabled  = true,
            size     = 6,
            passes   = 2,
            vibrancy = 0.17,
            popups   = true,
        },
    },

    animations = { enabled = true },

    dwindle = { preserve_split = true },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        -- Clicking a link in Discord etc. focuses the browser window.
        focus_on_activate       = true,
    },

    ecosystem = {
        no_update_news   = true,
        no_donation_nag  = true,
    },

    cursor = {
        -- Hide the cursor while typing.
        hide_on_key_press = true,
    },
})

-- "Balanced": quick ease-out curves, short durations, workspaces slide.
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 3,    bezier = "easeInOutCubic", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "easeOutQuint",  style = "slidevert" })

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,
    },
})

---------------------
---- KEYBINDINGS ----
---------------------

local mod = "SUPER"
local function key(k) return mod .. " + " .. k end

-- Apps
hl.bind(key("Return"),      hl.dsp.exec_cmd(terminal))
hl.bind("ALT + space",       hl.dsp.exec_cmd(menu))
hl.bind(key("R"),           hl.dsp.exec_cmd("rofi -show run -run-command 'uwsm app -- {cmd}'"))
hl.bind(key("Tab"),         hl.dsp.exec_cmd("rofi -show window"))
hl.bind(key("E"),           hl.dsp.exec_cmd(fileManager))
hl.bind(key("B"),           hl.dsp.exec_cmd(browser))
hl.bind(key("V"),           hl.dsp.exec_cmd("cliphist list | rofi -dmenu -display-columns 2 -p clipboard | cliphist decode | wl-copy"))
hl.bind(key("period"),      hl.dsp.exec_cmd("rofimoji --selector rofi --action copy"))
hl.bind(key("N"),           hl.dsp.exec_cmd("swaync-client --toggle-panel --skip-wait"))
hl.bind(key("SHIFT + C"),   hl.dsp.exec_cmd("hyprpicker --autocopy --format=hex"))

-- Session
hl.bind(key("Escape"),         hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(key("SHIFT + Escape"), hl.dsp.exec_cmd("wlogout --protocol layer-shell"))
hl.bind(key("SHIFT + Q"),      hl.dsp.exec_cmd("uwsm stop"))

-- Windows
hl.bind(key("Q"), hl.dsp.window.close())
hl.bind(key("F"), hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(key("M"), hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(key("T"), hl.dsp.window.float({ action = "toggle" }))
hl.bind(key("P"), hl.dsp.window.pseudo())
hl.bind(key("O"), hl.dsp.layout("togglesplit")) -- dwindle: flip split direction

-- Focus / move / resize: arrows and vim keys
local directions = {
    { keys = { "left",  "H" }, dir = "left",  dx = -40, dy = 0 },
    { keys = { "down",  "J" }, dir = "down",  dx = 0,   dy = 40 },
    { keys = { "up",    "K" }, dir = "up",    dx = 0,   dy = -40 },
    { keys = { "right", "L" }, dir = "right", dx = 40,  dy = 0 },
}
for _, d in ipairs(directions) do
    for _, k in ipairs(d.keys) do
        hl.bind(key(k),             hl.dsp.focus({ direction = d.dir }))
        hl.bind(key("SHIFT + " .. k), hl.dsp.window.move({ direction = d.dir }))
        hl.bind(key("CTRL + " .. k),  hl.dsp.window.resize({ x = d.dx, y = d.dy, relative = true }), { repeating = true })
    end
end

-- Workspaces 1-10; SHIFT moves the window along, ALT moves it silently.
for i = 1, 10 do
    local k = i % 10
    hl.bind(key(k),               hl.dsp.focus({ workspace = i }))
    hl.bind(key("SHIFT + " .. k), hl.dsp.window.move({ workspace = i, follow = true }))
    hl.bind(key("ALT + " .. k),   hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Scratchpad
hl.bind(key("S"),         hl.dsp.workspace.toggle_special("magic"))
hl.bind(key("SHIFT + S"), hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse: scroll through workspaces, drag to move (LMB) / resize (RMB)
hl.bind(key("mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(key("mouse_up"),   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(key("mouse:272"),  hl.dsp.window.drag(),   { mouse = true })
hl.bind(key("mouse:273"),  hl.dsp.window.resize(), { mouse = true })

-- Screenshots -> satty (annotate, then Ctrl+C copies / Ctrl+S saves to ~/Pictures/Screenshots)
local satty = "satty --filename - --early-exit --copy-command wl-copy"
    .. " --output-filename ~/Pictures/Screenshots/screenshot-%Y%m%d-%H%M%S.png"
hl.bind("Print",         hl.dsp.exec_cmd("grim -g \"$(slurp -d)\" - | " .. satty))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim - | " .. satty))

-- Media keys, with an on-screen display from swayosd
local locked_repeat = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"),       locked_repeat)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"),       locked_repeat)
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),  { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

--------------------------------
---- WINDOWS AND LAYERS ----
--------------------------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Small utility windows float, centred.
hl.window_rule({
    name  = "float-utilities",
    match = { class = "^(org.pulseaudio.pavucontrol|.blueman-manager-wrapped|nm-connection-editor|org.gnome.Calculator|com.gabm.satty|xdg-desktop-portal-gtk)$" },
    float = true,
    center = true,
})
hl.window_rule({
    name  = "float-dialogs",
    match = { title = "^(Open File|Open Folder|Save As|Save File|File Upload|Choose Files?).*" },
    float = true,
    center = true,
})
hl.window_rule({
    name  = "pip",
    match = { title = "^Picture-in-Picture$" },
    float = true,
    pin   = true,
    keep_aspect_ratio = true,
})

-- Don't let the screen lock/blank while something is fullscreen (videos, games).
hl.window_rule({
    name  = "idle-inhibit-fullscreen",
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
})

-- Blur behind the bar, launcher, notifications and logout menu.
hl.layer_rule({ match = { namespace = "^(waybar|rofi|swaync-control-center|swaync-notification-window|logout_dialog|swayosd)$" }, blur = true, ignore_alpha = 0.3 })
