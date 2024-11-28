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
    hash = "sha256-q9W4/s9J+v4OjTA7eL8FW3eWJT4ajdKPefX+i1Jj0rM=";
  };

  buildInputs = [ sbcl ];

  installPhase = ''
    curl -O https://beta.quicklisp.org/quicklisp.lisp
    sbcl --load "./quicklisp.lisp" --eval "(quicklisp-quickstart:install)"
    make build
    install -m755 -D bin/sbcl/qob $out/bin/qob
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
