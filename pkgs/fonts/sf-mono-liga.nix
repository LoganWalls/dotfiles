{
  sf-mono-liga,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "sf-mono-liga-bin";
  version = "dev";
  src = sf-mono-liga;
  dontConfigure = true;
  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    cp -R $src/*.otf $out/share/fonts/opentype/
  '';
}
