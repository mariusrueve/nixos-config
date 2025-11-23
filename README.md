# NixOS Configuration

This repository contains my personal NixOS configuration files, managed using Nix Flakes.

## Structure

- `flake.nix`: The entry point for the NixOS configuration.
- `home/`: Contains home-manager configurations for different users.
- `hosts/`: Contains system-specific configurations for different machines.
- `modules/`: Contains shared NixOS modules that can be reused across different hosts.

## Usage

To build a system configuration from this flake, run:

```bash
nixos-rebuild switch --flake .#<hostname>
```

Where `<hostname>` is one of the hosts defined in the `hosts` directory.
