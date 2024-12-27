# When you add custom packages, list them here
# These are similar to nixpkgs packages
{
  inputs,
  pkgs,
}: {
  sf-mono-liga = pkgs.callPackage ./fonts/sf-mono-liga.nix {inherit (inputs) sf-mono-liga;};
  apple-fonts = pkgs.callPackage ./fonts/apple-fonts.nix {};
  ligalex-mono = pkgs.callPackage ./fonts/ligalex-mono.nix {};
}
