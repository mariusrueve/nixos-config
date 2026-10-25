# Home Manager entry point for marius on the MacBook.
{
  imports = [
    ./common
    ./common/kitty.nix
    ./common/ssh.nix
    ./darwin
  ];
}
