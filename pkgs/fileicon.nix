{
  stdenv,
  lib,
  fetchFromGitHub,
  installShellFiles,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "fileicon";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "mklement0";
    repo = "fileicon";
    rev = "v${version}";
    sha256 = "sha256-kL5EpGYykkCpV/LIUiek+ijOOMEt+FBG84uiqTe/ZLs=";
  };

  nativeBuildInputs = [installShellFiles makeWrapper];

  dontBuild = true;

  installPhase = ''
    mkdir -p "$out"
    mv bin "$out"
    runHook postInstall;
  '';

  postInstall = ''
    wrapProgram "$out/bin/fileicon" --prefix PATH : /usr/bin/osascript
    installManPage man/fileicon.1
  '';

  meta = with lib; {
    description = "A command line utility for managing file icons in macOS";
    homepage = "https://github.com/mklement0/fileicon";
    license = licenses.mit;
    maintainers = [maintainers.loganwalls];
    platforms = platforms.all;
  };
}
