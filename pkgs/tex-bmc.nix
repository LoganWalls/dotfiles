{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  version = "master-17-04-2021";
  pname = "bmc";
  name = "${pname}-${version}";
  tlType = "run";

  src = fetchFromGitHub {
    owner = "tecosaur";
    repo = "BMC";
    rev = "b03bc88416343295c1d17c7aaa7f4059a08ac459";
    hash = "sha256-YwhUVLF90K4ZGK1nvtVuZPzFikhSit7sqy43wHxe+jo=";
  };

  dontBuild = true;
  installPhase = ''
    path="$out/tex/latex/bmc"
    mkdir -p $path
    cp -prd . $path
  '';
}
