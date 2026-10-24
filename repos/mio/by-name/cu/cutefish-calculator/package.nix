{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  gettext,
  cutefish-toolkit,
}:

let
  cu = import ../cutefish/mk.nix { inherit lib; };
in
stdenv.mkDerivation {
  pname = "cutefish-calculator";
  version = cu.version "2026-10-23";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "calculator";
    rev = "7994fab9ca65098305c7d1e5b2f0affcd7d9189e";
    hash = "sha256-8xTwrG3aqDDKrROWpJUpWDkLYGItCKtA8GLWflAQm5E=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gettext
  ];

  buildInputs = [ cutefish-toolkit ];

  cmakeFlags = cu.cmakeFlags;

  meta = {
    inherit (cu) homepage platforms;
    description = "Calculator for the Cutefish desktop";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-calculator";
  };
}
