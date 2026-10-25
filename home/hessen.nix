# Home Manager entry point for mrueve on the uni server hessen (openSUSE, no root).
# Standalone Home Manager: homeConfigurations."mrueve@hessen" in flake.nix.
#
# Nix runs inside nix-user-chroot, which mounts /local/mrueve/nix as /nix,
# and HOME is /local/mrueve/home. The NFS home (/home/stud2022/mrueve) is
# shared by every server and stays free of /nix/store links; its ~/.bashrc only
# holds the hook that enters this environment. Setup: AGENTS.md, "hessen".
#
# Apply on hessen: cd /local/mrueve/nixos-config && git pull && home-manager switch --flake .#mrueve@hessen
#
# SGE jobs run on other nodes without /nix: job environments are uv venvs on
# /work or /scratch with a uv-managed Python (UV_PYTHON_INSTALL_DIR below).

{ lib, pkgs, config, ... }:

{
  imports = [
    ./common
  ];

  home.username = "mrueve";
  home.homeDirectory = "/local/mrueve/home";

  programs.home-manager.enable = true;

  # Non-NixOS tweaks: sources nix.sh (PATH, SSL certs), XDG_DATA_DIRS. The GPU
  # driver setup needs root and a display; this is a headless SSH box.
  targets.genericLinux = {
    enable = true;
    gpu.enable = false;
  };

  # Single-user Nix from the installer; this only writes ~/.config/nix/nix.conf.
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # Gerrit at the university wants the uni address.
  programs.git.settings.user.email = lib.mkForce "marius.rueve@uni-hamburg.de";

  home.packages = with pkgs; [
    uv
    kitty.terminfo # TERM=xterm-kitty coming from the Mac
  ];

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    COLORTERM = "truecolor";
    TERMINFO_DIRS = "${config.home.profileDirectory}/share/terminfo:/usr/share/terminfo";
    # uv's cache is on /local, venvs often on /work (NFS): hardlinks can't cross.
    UV_LINK_MODE = "copy";
    # Pythons installed by `uv python install` go to NFS, so venvs built from
    # them also work in SGE jobs on other nodes.
    UV_PYTHON_INSTALL_DIR = "/work/stud2022/mrueve/opt/uv-python";
  };

  programs.bash = {
    shellAliases.cdphd = "cd /local/mrueve/phd";
    # The login environment sometimes passes a useless TERM. Leave multiplexers alone.
    initExtra = ''
      if [[ -z "$TMUX" && (-z "$TERM" || "$TERM" == "vt220" || "$TERM" == "dumb") ]]; then
        export TERM="xterm-256color"
      fi
    '';
  };
}
