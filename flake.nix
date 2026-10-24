{
  description = "Marius' NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
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

    # Neovim configured entirely in Nix (programs.nixvim, see home/neovim/).
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, claude-code-nix, catppuccin, nixvim, ... }: {
    # Attribute name matches networking.hostName, so a bare
    # `nixos-rebuild switch` picks this configuration automatically.
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/desktop/configuration.nix
        home-manager.nixosModules.home-manager
        catppuccin.nixosModules.catppuccin
        {
          home-manager.sharedModules = [
            catppuccin.homeModules.catppuccin
            nixvim.homeModules.nixvim
          ];
        }
        { nixpkgs.overlays = [ claude-code-nix.overlays.default ]; }
      ];
    };
  };
}
