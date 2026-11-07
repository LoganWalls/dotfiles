{
  lib,
  stdenv,
  fetchurl,
  p7zip,
  cpio,
}:
stdenv.mkDerivation rec {
  pname = "apple-fonts";
  version = "03-01-2023";

  pro = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
    sha256 = "sha256-sn/mYi8fqWpwfHPcpmZtQ5w1sxLVsdR+DimA5hjrSyg=";
  };

  compact = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
    sha256 = "sha256-byQRcYdqhBdNS5m69Gm6+z+OJFTOoSPYULM/H7D3D18=";
  };

  mono = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
    sha256 = "sha256-bUoLeOOqzQb5E/ZCzq0cfbSvNO1IhW1xcaLgtV2aeUU=";
  };

  ny = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
    sha256 = "sha256-HC7ttFJswPMm+Lfql49aQzdWR2osjFYHJTdgjtuI+PQ=";
  };

  nativeBuildInputs = [p7zip cpio];

  sourceRoot = ".";

  dontUnpack = true;

  # Apple ships two DMG layouts: older ones contain a folder with an
  # installer .pkg, newer (APFS) ones unpack straight to the cpio Payload.
  installPhase = ''
    extractFonts() {
      local work
      work=$(mktemp -d)
      pushd "$work"
      7z x -y "$1"
      local pkg
      pkg=$(find . -type f -name '*.pkg' | head -n1)
      if [ -n "$pkg" ]; then
        7z x -y "$pkg"
      fi
      cpio -idm < "$(find . -type f -name 'Payload~' | head -n1)"
      find . -path '*/Library/Fonts/*' -type f -name '*.otf' -exec mv {} $out/share/fonts/opentype \;
      find . -path '*/Library/Fonts/*' -type f -name '*.ttf' -exec mv {} $out/share/fonts/truetype \;
      popd
      rm -rf "$work"
    }

    mkdir -p $out/share/fonts/opentype $out/share/fonts/truetype
    extractFonts ${pro}
    extractFonts ${mono}
    extractFonts ${compact}
    extractFonts ${ny}
  '';

  meta = {
    # Credit to: https://github.com/robbins for creating this derivation
    description = "Apple San Francisco, New York fonts";
    homepage = "https://developer.apple.com/fonts/";
    license = lib.licenses.unfree;
  };
}
