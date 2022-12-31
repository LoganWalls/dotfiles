{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  clang,
  boost,
  eigen,
  zlib,
  bzip2,
  xz,
}:
stdenv.mkDerivation rec {
  pname = "kenlm";
  version = "master";

  src = fetchFromGitHub {
    owner = "kpu";
    repo = pname;
    rev = "bcd4af619a2fa45f5876d8855f7876cc09f663af";
    hash = "sha256-ZQbtexUtB/5N/Rpvw8yc80TRde7eqlsoh2aN9LtL0K8=";
  };

  nativeBuildInputs = with pkgs; [cmake clang];

  buildInputs = with pkgs; [
    boost
    eigen
    zlib
    bzip2
    xz
  ];

  meta = with lib; {
    description = "KenLM estimates, filters, and queries n-gram language models.";
    homepage = "https://kheafield.com/code/kenlm/";
    license = licenses.lgpl21Plus;
    platforms = platforms.all;
  };
}
