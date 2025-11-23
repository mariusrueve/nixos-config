{ pkgs, ... }:

{
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.ly.enableGnomeKeyring = true;

  # Enable Sway Window Manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Display Manager: Ly
  services.displayManager.ly.enable = true;

  # Necessary for Wayland to work correctly (screensharing, etc)
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Security for Wayland (polkit)
  security.polkit.enable = true;

  # Common Sway packages
  environment.systemPackages = with pkgs; [
    wl-clipboard   # Clipboard manager
    mako           # Notification daemon
    wofi           # App launcher (alternative to dmenu/rofi)
    waybar         # Status bar
    grim           # Screenshots
    slurp          # Area selection for screenshots
    seahorse
    libsecret
  ];
}
