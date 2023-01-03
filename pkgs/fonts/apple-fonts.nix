{
  lib,
  stdenv,
  fetchurl,
  unzip,
  p7zip,
}:
stdenv.mkDerivation rec {
  pname = "apple-fonts";
  version = "03-01-2023";

  pro = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
    sha256 = "0z3cbaq9dk8dagjh3wy20cl2j48lqdn9q67lbqmrrkckiahr1xw3";
  };

  compact = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
    sha256 = "04sq98pldn9q1a1npl6b64karc2228zgjj4xvi6icjzvn5viqrfj";
  };

  mono = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
    sha256 = "0fdcras7y7cvym6ahhgn7ih3yfkkhr9s6h5b6wcaw5svrmi6vbxb";
  };

  ny = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
    sha256 = "1q0b741qiwv5305sm3scd9z2m91gdyaqzr4bd2z54rvy734j1q0y";
  };

  nativeBuildInputs = [p7zip];

  sourceRoot = ".";

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out

    7z x ${pro}
    cd SFProFonts
    7z x 'SF Pro Fonts.pkg'
    7z x 'Payload~'
    mkdir -p $out/fontfiles
    mv Library/Fonts/* $out/fontfiles
    cd ..

    7z x ${mono}
    cd SFMonoFonts
    7z x 'SF Mono Fonts.pkg'
    7z x 'Payload~'
    mv Library/Fonts/* $out/fontfiles
    cd ..

    7z x ${compact}
    cd SFCompactFonts
    7z x 'SF Compact Fonts.pkg'
    7z x 'Payload~'
    mv Library/Fonts/* $out/fontfiles
    cd ..

    7z x ${ny}
    cd NYFonts
    7z x 'NY Fonts.pkg'
    7z x 'Payload~'
    mv Library/Fonts/* $out/fontfiles

    mkdir -p $out/share/fonts/opentype $out/share/fonts/truetype
    mv $out/fontfiles/*.otf $out/share/fonts/opentype
    mv $out/fontfiles/*.ttf $out/share/fonts/truetype
    rm -rf $out/fontfiles
  '';

  meta = {
    # Credit to: https://github.com/robbins for creating this derivation
    description = "Apple San Francisco, New York fonts";
    homepage = "https://developer.apple.com/fonts/";
    license = lib.licenses.unfree;
  };
}
