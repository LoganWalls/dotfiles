{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:
stdenv.mkDerivation {
  pname = "maple-mono";
  version = "26-09-2025";

  src = fetchurl {
    url = "https://github.com/LoganWalls/maple-font/releases/download/v1758940385/MapleMono-OTF.zip";
    sha256 = "0f7d6f9c067daeae9cb89e916adf19f4324f5c74d535db7492c084bd2483740e";
  };

  nativeBuildInputs = [unzip];

  dontInstall = true;

  unpackPhase = ''
    mkdir -p $out/share/fonts
    unzip -d $out/share/fonts/opentype $src
  '';

  meta = {
    description = "Maple Mono";
    homepage = "https://font.subf.dev/";
    license = lib.licenses.ofl;
  };
}
