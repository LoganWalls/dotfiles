{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:
stdenv.mkDerivation {
  pname = "ligalex-mono";
  version = "02-11-2024";

  src = fetchurl {
    url = "https://github.com/tdarshana/homebrew-blex-mono-liga-powerline/releases/download/rel-v0.1/ligalex-mono-powerline.zip";
    sha256 = "7a68ec36c048402f8874cc0ec7a2cc2762e59aec70505a50b7cebf5c3af4c440";
  };

  nativeBuildInputs = [unzip];

  dontInstall = true;

  unpackPhase = ''
    mkdir -p $out/share/fonts
    unzip -d $out/share/fonts/truetype $src
  '';

  meta = {
    description = "Ligaturized Blex Mono font";
    homepage = "https://github.com/tdarshana/homebrew-blex-mono-liga-powerline/";
    license = lib.licenses.ofl;
  };
}
