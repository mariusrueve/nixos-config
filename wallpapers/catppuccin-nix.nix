# Catppuccin Mocha wallpaper with the official NixOS snowflake (from
# nixos-artwork via pkgs.nixos-icons), recoloured to the Mocha palette.
# Build standalone:
#   nix build --impure --expr '(import ./wallpapers/catppuccin-nix.nix {
#     pkgs = (builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.x86_64-linux; })'

{
  pkgs,
  width ? 3840,
  height ? 2160,
  logoSize ? 1100,
  withText ? false,
}:

let
  # Catppuccin Mocha
  base = "#1e1e2e";
  crust = "#11111b";
  overlay0 = "#6c7086";
  blue = "#89b4fa";
  lavender = "#b4befe";
  sapphire = "#74c7ec";
  sky = "#89dceb";

  font = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans-Bold.ttf";
  textSize = logoSize / 7;
  textOffset = logoSize / 2 + textSize;
in
pkgs.runCommand "catppuccin-mocha-nix-${toString width}x${toString height}.png"
  {
    nativeBuildInputs = [
      pkgs.resvg
      pkgs.imagemagick
    ];
  }
  ''
    # Official gradient stops: dark lambdas, then light lambdas.
    sed \
      -e 's/#415e9a/${blue}/g' -e 's/#4a6baf/${lavender}/g' -e 's/#5277c3/${blue}/g' \
      -e 's/#699ad7/${sapphire}/g' -e 's/#7eb1dd/${sky}/g' -e 's/#7ebae4/${sapphire}/g' \
      ${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg > logo.svg
    resvg -h ${toString logoSize} logo.svg logo.png

    magick -size ${toString width}x${toString height} \
      -define gradient:extent=diagonal radial-gradient:'${base}'-'${crust}' \
      logo.png -gravity center -composite \
      ${pkgs.lib.optionalString withText ''
        -font ${font} -pointsize ${toString textSize} -fill '${overlay0}' \
        -annotate +0+${toString textOffset} 'NixOS' \
      ''} \
      -dither FloydSteinberg -depth 8 -strip $out
  ''
