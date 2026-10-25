# Home Manager entry point for marius on the NixOS desktop.
{
  imports = [
    ./common
    ./common/kitty.nix
    ./linux
  ];
}
