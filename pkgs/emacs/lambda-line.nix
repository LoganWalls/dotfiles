{
  lib,
  trivialBuild,
  fetchFromGitHub,
  emacs,
  all-the-icons,
}:
trivialBuild rec {
  pname = "lambda-line";
  version = "main-23-11-2022";

  src = fetchFromGitHub {
    owner = "Lambda-Emacs";
    repo = "lambda-line";
    rev = "22186321a7442f1bd3b121f739007bd809cb38f8";
    hash = "sha256-2tOXMqpmd14ohzmrRoV5Urf0HlnRPV1EVHm/d8OBSGE=";
  };

  propagatedUserEnvPkgs = [
    all-the-icons
  ];

  buildInputs = propagatedUserEnvPkgs;

  meta = with lib; {
    homepage = "https://github.com/Lambda-Emacs/lambda-line";
    description = "Lambda-line is a custom status-line (or “mode-line) for Emacs. It is configurable for use either as a header-line or as a footer-line.";
    license = licenses.gpl3;
    inherit (emacs.meta) platforms;
  };
}
