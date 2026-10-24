{
  description = "LaTeX document (latexmk + full TeX Live)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
    in
    {
      # In nvim: Space ll compiles continuously, Space lv shows the PDF.
      # Without nvim: `latexmk -pdf main.tex`.
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = [ nixpkgs.legacyPackages.${system}.texliveFull ];
        };
      });
    };
}
