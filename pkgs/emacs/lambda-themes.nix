{
  lib,
  trivialBuild,
  fetchFromGitHub,
  emacs,
}:
trivialBuild rec {
  pname = "lambda-themes";
  version = "main-27-11-2022";

  src = fetchFromGitHub {
    owner = "Lambda-Emacs";
    repo = "lambda-themes";
    rev = "fd02934ab31d051eb5ec6350830c252185404434";
    hash = "sha256-L+ZaBAmHJf6DFY1bdfynFs/ufiEIWeBRMa+WBs3+DEA=";
  };

  # propagatedUserEnvPkgs = [
  #   all-the-icons
  # ];
  #
  # buildInputs = propagatedUserEnvPkgs;

  meta = with lib; {
    homepage = "https://github.com/Lambda-Emacs/lambda-themes";
    description = "A set of four light and dark themes for Emacs.";
    license = licenses.gpl3;
    inherit (emacs.meta) platforms;
  };
}
