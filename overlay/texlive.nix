final: prev: let
  pkgs = final;
  inherit (pkgs) callPackage texlive;
  bmc.pkgs = [(callPackage (import ../pkgs/tex-bmc.nix) {inherit (pkgs) stdenv fetchFromGitHub;})];
in {
  my-texlive = texlive.combine {
    inherit
      (texlive)
      scheme-basic
      latexmk
      xetex
      dvisvgm
      dvipng
      wrapfig
      amsmath
      mathtools
      mathdesign
      ulem
      hyperref
      capt-of
      xcolor
      booktabs
      cancel
      arev
      bera
      ;
    inherit bmc;
  };
}
