# macOS Home Manager config (on top of home/common).

{ pkgs, ... }:

{
  imports = [
    ./aerospace.nix
  ];

  # macOS-only CLI programs. GUI apps: homebrew.casks in hosts/macbook/default.nix.
  # (Shared ones: home/common/default.nix.)
  home.packages = with pkgs; [
  ];

  # LabRoute (Homebrew cask) writes its own ssh hosts to ~/.ssh/labroute/config.
  # Its Add buttons can't edit the Nix-managed ~/.ssh/config and only know zsh,
  # so both hooks live here. Home Manager puts Include at the top, as LabRoute needs.
  programs.ssh.includes = [ "~/.ssh/labroute/config" ];
  # Before every prompt: export http(s)_proxy while LabRoute runs, unset them otherwise.
  programs.bash.initExtra = ''
    if [ -x /Applications/LabRoute.app/Contents/MacOS/labroute ]; then
      _labroute_env() { eval "$(/Applications/LabRoute.app/Contents/MacOS/labroute env)"; }
      PROMPT_COMMAND="''${PROMPT_COMMAND:+$PROMPT_COMMAND;}_labroute_env"
    fi
  '';

  # Target of system.defaults.screencapture.location.
  home.file."Pictures/Screenshots/.keep".text = "";
}
