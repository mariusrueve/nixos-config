# System + Home Manager configuration for host "desktop".
# Option docs: configuration.nix(5), home-configuration.nix(5), https://search.nixos.org/options

{ config, pkgs, ... }:

{
  # Home Manager and the claude-code overlay are wired in via flake.nix.
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Hyprland desktop: greeter, portals, GPU env, desktop services.
      ./modules/desktop.nix
      # Hourly snapper snapshots of /home.
      ./modules/snapshots.nix
    ];

  # This system is built from flake.nix; inputs are pinned in flake.lock.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Keep the Nix store from growing without bound.
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  # Cap boot entries so old kernels/initrds can't fill the 1 GiB ESP.
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # btrfs: transparent compression and no access-time writes. Set here rather
  # than in hardware-configuration.nix, which nixos-generate-config overwrites.
  # Compression only applies to data written after the remount/reboot.
  fileSystems = {
    "/".options = [ "compress=zstd" "noatime" ];
    "/home".options = [ "compress=zstd" "noatime" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
  };

  # Monthly checksum scrub. All subvolumes share one filesystem, so "/" covers them.
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
  };

  # Compressed swap in RAM (zstd, up to 50% of RAM), used before the disk swap
  # partition, which stays as overflow.
  zramSwap.enable = true;

  # Firmware updates (UEFI, SSD, peripherals) via `fwupdmgr`.
  services.fwupd.enable = true;

  # Lets prebuilt, non-Nix binaries (npm/pip wheels, downloaded tools) find a
  # dynamic linker and common libraries.
  programs.nix-ld.enable = true;

  networking.hostName = "desktop";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Configure keymap in X11 (Hyprland's own layout is set in home/hyprland.nix)
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable OpenGL
  hardware.graphics.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Save VRAM across suspend (nvidia-suspend/resume services). Without it,
    # Wayland sessions commonly resume to a black or corrupted screen.
    powerManagement.enable = true;
    # Fine-grained power management. Turns off GPU when not in use.
    # Only needed on laptops with hybrid (iGPU + dGPU) setups.
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Recommended for Turing and later GPUs (RTX 4070 is Ada Lovelace).
    open = true;

    # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Use the stable NVidia driver package.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."marius" = {
    isNormalUser = true;
    description = "Marius";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.bashInteractive;
    packages = with pkgs; [
      # thunderbird
      spotify
      claude-code
      discord
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Home Manager: per-user dotfiles, tracked in this same repo.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # If an unmanaged file is in the way, rename it to *.hm-backup instead of failing activation.
  home-manager.backupFileExtension = "hm-backup";
  home-manager.users.marius = import ./home;

  # System-wide packages (gh is managed by Home Manager in home/).
  environment.systemPackages = with pkgs; [
    git
    pciutils
    inxi
    htop
    ripgrep
    fd
    fzf
    unzip
    zip
    wget
    curl
    lazygit
  ];

  # Allow running `nixos-rebuild` without re-entering the sudo password each
  # time, so config changes can be applied in one step. Scoped to exactly
  # this command (not sudo in general).
  security.sudo.extraRules = [
    {
      users = [ "marius" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # The NixOS release this machine was first installed with; keeps stateful data
  # (databases etc.) compatible. It does NOT control the package versions and must
  # never be bumped on upgrades. See the `system.stateVersion` option docs.
  system.stateVersion = "26.05";
}
