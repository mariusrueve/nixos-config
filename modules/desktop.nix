# System side of the Hyprland desktop: compositor, greeter, portals, GPU
# environment and the services a desktop session expects.
# Per-user Hyprland/bar/theme config lives in ../home/.

{ config, pkgs, ... }:

{
  # Hyprland, launched as a systemd session via UWSM (Universal Wayland Session
  # Manager), so user services bound to graphical-session.target (waybar,
  # swaync, hypridle, ...) start and stop with it.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Login: greetd + tuigreet on the TTY. Sessions come from the installed
  # wayland-sessions; the last-used one is remembered.
  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "greeter";
      command = builtins.concatStringsSep " " [
        "${pkgs.tuigreet}/bin/tuigreet"
        "--time"
        "--remember"
        "--remember-session"
        "--asterisks"
        "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
        "--cmd 'uwsm start hyprland-uwsm.desktop'"
      ];
    };
  };
  # Keep kernel/systemd boot messages from being printed over the greeter.
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Catppuccin Mocha palette for the Linux console (and thus tuigreet).
  catppuccin = {
    flavor = "mocha";
    accent = "blue";
    tty.enable = true;
  };

  # Secrets: gnome-keyring is unlocked with the login password, so apps that
  # store credentials (Discord, Spotify, browsers) keep working as under GNOME.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  # PAM service for the hyprlock screen locker.
  programs.hyprlock.enable = true;
  security.polkit.enable = true;

  # Required for Home Manager's dconf module (GTK dark mode etc.).
  programs.dconf.enable = true;

  # Portals: Hyprland's (screenshare, screenshots; added by programs.hyprland)
  # plus GTK's for file pickers and settings.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.hyprland.default = [ "hyprland" "gtk" ];
  };

  # Two GPUs: AMD iGPU (PCI 10:00.0) and the RTX 4070 (PCI 01:00.0), which
  # drives the monitor. /dev/dri/cardN numbering is not stable across boots, so
  # give the NVIDIA card a fixed name for AQ_DRM_DEVICES (see home/linux/hyprland.nix).
  services.udev.extraRules = ''
    KERNEL=="card*", KERNELS=="0000:01:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/nvidia-gpu"
  '';

  # VA-API on NVIDIA (hardware video decoding in Firefox/mpv).
  hardware.graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ];

  # Electron/Chromium apps (Discord, Spotify, ...) run natively on Wayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # GNOME used to enable these implicitly.
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.gvfs.enable = true; # Nautilus trash, MTP, network shares
  services.udisks2.enable = true; # removable drives (udiskie)
  services.upower.enable = true;

  # Nautilus: quick-look previews (space) and "Open in kitty" in the context menu.
  services.gnome.sushi.enable = true;
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono # terminal, editors, bar icons
    inter # UI font: bar, launcher, notifications
    noto-fonts
    noto-fonts-color-emoji
  ];

  environment.systemPackages = with pkgs; [
    # GNOME apps kept after dropping the GNOME desktop.
    nautilus
    loupe
    papers
    file-roller
    gnome-calculator
    gnome-text-editor

    # Desktop utilities used by the Hyprland keybinds and Waybar.
    pavucontrol
    networkmanagerapplet # nm-connection-editor (Waybar network click)
    playerctl
    wl-clipboard
    hyprpicker
    grim
    slurp
    hyprshot
    satty
    rofimoji
    libnotify
  ];
}
