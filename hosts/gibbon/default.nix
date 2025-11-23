{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "gibbon";

  # You can add specific gibbon-only overrides here
  # e.g., if gibbon needs specific bluetooth drivers or power settings
}
