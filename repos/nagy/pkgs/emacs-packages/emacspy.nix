{
  lib,
  melpaBuild,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  python3,
}:

let
  libExt = stdenv.hostPlatform.extensions.sharedLibrary;
in
melpaBuild {
  pname = "emacspy";
  version = "0-unstable-2023-03-04";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "emacspy";
    rev = "4ca5c169df7c4ddc1ff6cbe4ec3e13227a4abcf9";
    hash = "sha256-r4o8aBr0j2DsUxXQZkZyDMlDGcrG1cpG0AWVCSWegVQ=";
  };

  preBuild = ''
    rm emacs-module.h
    make
    mv emacspy.so emacspy-core.so
    echo -e "(require 'emacspy-core)\n(provide 'emacspy)" > emacspy.el
  '';

  nativeBuildInputs = [
    pkg-config
    python3.pkgs.cython
  ];

  files = ''(:defaults "emacspy-core${libExt}")'';

  meta = {
    homepage = "https://github.com/zielmicha/emacspy";
    description = "Program Emacs in Python instead of ELisp (i.e. write dynamic modules for Emacs in Python)";
    maintainers = [ lib.maintainers.nagy ];
    license = lib.licenses.mit;
  };
}
