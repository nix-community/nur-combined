{
  lib,
  stdenv,
  fetchFromGitHub,
  pkgs,
}:

stdenv.mkDerivation rec {
  pname = "qob-cli";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "cl-qob";
    repo = "cli";
    rev = version;
    hash = "sha256-81S/5Ff2a4caoZhysPvnXLVRXlJBg6alR/afsF170kc=";
  };

  sbcl' = pkgs.sbcl.withPackages (ps: with ps; [
    copy-directory
    clingon
    deploy
  ]);

  buildInputs = [ sbcl' ];

  buildPhase = ''
    sbcl --eval "(progn (require :asdf) (asdf:load-system :clingon))"
  '';

  # buildFlags = [ "build" ];
  #
  # installPhase = ''
  #   install -m755 -D bin/sbcl/qob $out/bin/qob
  # '';

  # prevent corrupting core in exe
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
