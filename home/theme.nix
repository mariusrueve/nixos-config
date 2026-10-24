# Look & feel: Catppuccin Mocha with a blue accent everywhere.
# catppuccin/nix themes every enabled program it supports (kitty, tmux, zathura,
# rofi, waybar, hyprland, hyprlock, swaync, wlogout, fzf, starship, ...).

{ pkgs, ... }:

{
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";

    cursors = {
      enable = true;
      accent = "dark";
    };
    # Papirus icons with Catppuccin-coloured folders.
    gtk.icon.enable = true;
    # Qt apps via Kvantum.
    kvantum = {
      enable = true;
      apply = true;
    };
    swaync.font = "Inter";
  };

  home.pointerCursor = {
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };

  # GTK3 apps: adw-gtk3 matches libadwaita (GTK4) apps; both go dark via the
  # color-scheme setting below.
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    font = {
      name = "Inter";
      size = 11;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    font-name = "Inter 11";
    monospace-font-name = "JetBrainsMono Nerd Font 11";
  };

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };
}
