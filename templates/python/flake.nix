{
  description = "Python research environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # Compiled/scientific packages come from nixpkgs (prebuilt, reproducible).
          python = pkgs.python3.withPackages (ps: with ps; [
            rdkit
            numpy
            pandas
            scikit-learn
            matplotlib
            ipython
            pytest
          ]);
        in
        {
          default = pkgs.mkShell {
            packages = [ python pkgs.uv ];

            # Anything not in nixpkgs: `uv pip install <pkg>` into .venv, which
            # sits on top of (and can see) the nixpkgs packages above.
            shellHook = ''
              if [ ! -d .venv ]; then
                uv venv --quiet --python ${python}/bin/python --system-site-packages .venv
              fi
              source .venv/bin/activate
              export UV_PYTHON=$PWD/.venv/bin/python
            '';
          };
        }
      );
    };
}
