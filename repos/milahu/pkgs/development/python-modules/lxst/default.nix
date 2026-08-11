# based on https://github.com/NixOS/nixpkgs/pull/421656

{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  lxmf,
  numpy,
  pycodec2,
  rns,
  soundcard,
  audioop-lts,
}:

buildPythonPackage rec {
  pname = "lxst";
  version = "0.4.4-unstable-2025-12-28";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "markqvist";
    repo = "lxst";
    rev = "1194c9011fe6402edc7aebe7ffe9650ea3b1afee";
    hash = "sha256-/NXMGR5v81m1WDtyiKkizXJ/dbRr6m8zp/viVosyahQ=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    pycodec2
    numpy
    rns
    lxmf
    soundcard
    audioop-lts
  ];

  meta = {
    description = "Simple and flexible real-time streaming format and delivery protocol for Reticulum";
    homepage = "https://github.com/markqvist/LXST";
    license = lib.licenses.cc-by-nc-nd-40;
    mainProgram = "rnphone";
  };
}
