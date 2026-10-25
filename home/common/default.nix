# Home Manager config shared by ALL hosts (desktop, MacBook, hessen):
# shell, editor, git, CLI tools, theme. Linux-desktop-only bits live in
# home/linux/, macOS-only bits in home/darwin/, the uni server in home/hessen.nix.
# Option docs: home-configuration.nix(5)

{ pkgs, ... }:

{
  # kitty.nix and ssh.nix are imported per host (home/desktop.nix, home/macbook.nix):
  # the headless uni server (home/hessen.nix) has no GUI terminal and is an SSH target.
  imports = [
    ./neovim # editor (nixvim)
  ];

  home.stateVersion = "26.05";

  # ── Your programs (all hosts) ──────────────────────────────────────────
  # Add a package name here, then apply with:
  #   desktop: cd ~/nixos-config && sudo nixos-rebuild switch --flake .
  #   MacBook: cd ~/nixos-config && sudo darwin-rebuild switch --flake .
  #   hessen:  cd /local/mrueve/nixos-config && git pull && home-manager switch --flake .#mrueve@hessen
  # Find names at https://search.nixos.org/packages or `nix search nixpkgs <name>`.
  # Only on one machine? → home/linux/default.nix or home/darwin/default.nix.
  # Mac GUI apps → homebrew.casks in hosts/macbook/default.nix.
  home.packages = with pkgs; [
    fastfetch
    ripgrep
    fd
    jq
    tree
    wget
    unzip
    zip
    lazygit
  ];

  # Claude Code. Home Manager writes ~/.claude/settings.json as a read-only
  # symlink, so settings changed through /config won't save: change them here.
  # The rest of ~/.claude/ (sessions, history, memory, plugins) is Claude
  # Code's own state and stays unmanaged.
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code; # from the claude-code-nix overlay (always up to date)
    settings = {
      theme = "auto";
      modelSettings."claude-opus-5-5".autoCompactWindow = 400000;
      # No Co-Authored-By trailer or PR footer.
      attribution = {
        commit = "";
        pr = "";
        sessionUrl = false;
      };
    };
  };

  # OpenAI Codex CLI (`codex`). Config in ~/.codex/ stays unmanaged.
  programs.codex = {
    enable = true;
    package = pkgs.codex; # from the codex-cli-nix overlay (always up to date)
  };

  # Catppuccin Mocha, blue accent, for every supported program on both machines.
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };

  # Git config lives in ~/.config/git/config. The identity uses GitHub's noreply
  # address (id+login), which GitHub always links to the account; without it the
  # Mac fell back to marius@<hostname> and commits showed up unlinked.
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true; # no merge commits from `git pull`
      rebase.autoStash = true;
      push.autoSetupRemote = true; # first `git push` of a new branch just works
      fetch.prune = true;
      diff.algorithm = "histogram";
      merge.conflictStyle = "zdiff3";
      rerere.enabled = true; # remember resolved conflicts
      user = {
        name = "Marius Rüve";
        email = "44000950+mariusrueve@users.noreply.github.com";
      };
    };
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
    # tmux-256color (not "screen") gives nvim italics/undercurl; the RGB
    # feature passes truecolor through to kitty.
    terminal = "tmux-256color";
    escapeTime = 10;
    mouse = true;
    focusEvents = true; # nvim autoread / gitsigns refresh on pane focus
    clock24 = true;
    extraConfig = ''
      set -as terminal-features ',xterm-kitty:RGB'
    '';
  };

  # Ctrl-R fuzzy history, Ctrl-T insert file, Alt-C cd into directory.
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
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

  # Prompt. Colours from catppuccin (above).
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
