{
  lib,
  stdenv,
  fetchFromGitHub,
  sbcl,
}:

stdenv.mkDerivation rec {
  pname = "qob-cli";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "cl-qob";
    repo = "cli";
    rev = version;
    hash = "sha256-FgmeAsqbnlw7yOMslAJnZWuG3nDDjcXlS2pI3X9x1PA=";
  };

  buildInputs = [ sbcl ];

  buildPhase = ''
    make build
  '';

  dontStrip = true;

  meta = {
    changelog = "https://github.com/cl-qob/cli/blob/${src.rev}/CHANGELOG.md";
    description = "CLI for building, runing, testing, and managing your Common Lisp dependencies";
    homepage = "https://cl-qob.github.io/";
    license = lib.licenses.mit;
    mainProgram = "qob";
    maintainers = with lib.maintainers; [
      jcs090218
    ];
  };
}
