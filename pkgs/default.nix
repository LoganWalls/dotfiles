# When you add custom packages, list them here
# These are similar to nixpkgs packages
{
  pkgs,
  inputs,
}: let
  inherit (pkgs) callPackage stdenv lib;
in {
  kenlm = callPackage ./kenlm.nix {
    inherit stdenv lib;
    inherit
      (pkgs)
      boost
      bzip2
      cmake
      clang
      eigen
      fetchFromGitHub
      xz
      zlib
      ;
  };
  fileicon = pkgs.callPackage ./fileicon.nix {
    inherit stdenv lib;
    inherit
      (pkgs)
      fetchFromGitHub
      installShellFiles
      makeWrapper
      ;
  };
  sf-mono-liga = pkgs.callPackage ./fonts/sf-mono-liga.nix {
    inherit (inputs) sf-mono-liga;
    inherit (pkgs) stdenvNoCC;
  };
  apple-fonts = pkgs.callPackage ./fonts/apple-fonts.nix {
    inherit (pkgs) lib stdenv fetchurl unzip p7zip;
  };
}
