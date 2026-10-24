# Home Manager configuration for marius (imported from configuration.nix).
# Option docs: home-configuration.nix(5)

{ pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./services.nix
    ./apps.nix
    ./theme.nix
  ];

  home.stateVersion = "26.05";

  # Theme comes from catppuccin (home/theme.nix).
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings.editor = {
      line-number = "relative";
      cursorline = true;
      bufferline = "multiple";
      color-modes = true;
    };
  };

  # Git config lives in ~/.config/git/config. User identity stays in ~/.gitconfig.
  programs.git = {
    enable = true;
    settings.init.defaultBranch = "main";
  };

  # gh as git's credential helper for GitHub. Home Manager regenerates the
  # helper's /nix/store path on each rebuild and keeps it alive as a GC root;
  # a hand-run `gh auth setup-git` writes a path that GC eventually deletes.
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  # Per-project dev environments: `use flake` in an .envrc loads that
  # project's devShell on cd.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.tmux = {
    enable = true;
    sensibleOnTop = true;
    keyMode = "vi";
    historyLimit = 10000;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = false;
    viAlias = true;
    vimAlias = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;

    historySize = 10000;
    historyFileSize = 10000;
    historyControl = [ "ignoredups" "erasedups" ];
    # Append to (rather than overwrite) the history file, so parallel shells
    # don't clobber each other's history.
    shellOptions = [ "histappend" "checkwinsize" "globstar" ];

    shellAliases = {
      # Same meaning as before, now via eza (icons + git status column).
      ll = "eza -la";
      la = "eza -A";
      ".." = "cd ..";
      gs = "git status";
    };
  };

  # Prompt. Colours from catppuccin (home/theme.nix).
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  # Modern CLI tools. catppuccin themes bat, btop and yazi.
  # `ls`/`lt`/`lla` aliases come from eza's shell integration.
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };
  programs.bat.enable = true;
  # `z <part of a dir name>` jumps to frequently used directories.
  programs.zoxide.enable = true;
  programs.btop.enable = true;
  # Terminal file manager; `y` opens it and cds into the last directory on exit.
  programs.yazi.enable = true;
}
