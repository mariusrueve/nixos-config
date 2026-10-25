{
  description = "Marius' NixOS desktop + nix-darwin MacBook configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # macOS-tested branch of the same release (better binary-cache hits on the Mac).
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # Always-up-to-date claude-code package (nixpkgs' build lags upstream releases).
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Catppuccin themes as NixOS/Home Manager modules (catppuccin.flavor etc.).
    catppuccin = {
      url = "github:catppuccin/nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim configured entirely in Nix (programs.nixvim, see home/common/neovim/).
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-darwin,
      home-manager,
      nix-darwin,
      claude-code-nix,
      catppuccin,
      nixvim,
      ...
    }:
    let
      overlays = [ claude-code-nix.overlays.default ];
      # Home Manager modules every configuration loads (desktop, macbook, hessen).
      hmModules = [
        catppuccin.homeModules.catppuccin
        nixvim.homeModules.nixvim
      ];

      # Used by both system hosts: overlays + Home Manager plumbing + shared HM modules.
      shared = {
        nixpkgs.overlays = overlays;
        nixpkgs.config.allowUnfree = true;

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          # If an unmanaged file is in the way, rename it to *.hm-backup instead of failing.
          backupFileExtension = "hm-backup";
          sharedModules = hmModules;
        };
      };
    in
    {
      # Attribute name matches networking.hostName, so a bare
      # `nixos-rebuild switch` picks this configuration automatically.
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/desktop/configuration.nix
          home-manager.nixosModules.home-manager
          catppuccin.nixosModules.catppuccin
          shared
        ];
      };

      # MacBook (Apple Silicon). First time: `sudo nix run nix-darwin -- switch --flake ~/nixos-config#macbook`,
      # afterwards `sudo darwin-rebuild switch --flake ~/nixos-config`.
      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        modules = [
          ./hosts/macbook
          home-manager.darwinModules.home-manager
          shared
        ];
      };

      # Uni server hessen (openSUSE, no root): standalone Home Manager inside
      # nix-user-chroot. On hessen: `home-manager switch --flake .#mrueve@hessen`.
      # Setup and constraints: AGENTS.md and home/hessen.nix.
      homeConfigurations."mrueve@hessen" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          inherit overlays;
          config.allowUnfree = true;
        };
        modules = hmModules ++ [ ./home/hessen.nix ];
      };

      # Per-project dev environments (both machines):
      #   mkdir myproject && cd myproject && nix flake init -t ~/nixos-config#python && direnv allow
      templates = {
        python = {
          path = ./templates/python;
          description = "Python + RDKit/numpy/pandas/scikit-learn (+ uv for extra PyPI packages)";
        };
        rust = {
          path = ./templates/rust;
          description = "Rust toolchain (rustc, cargo, clippy, rustfmt, rust-analyzer)";
        };
        latex = {
          path = ./templates/latex;
          description = "LaTeX document/thesis with latexmk and full TeX Live";
        };
      };
    };
}
