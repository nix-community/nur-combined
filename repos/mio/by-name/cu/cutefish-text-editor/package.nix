{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  gettext,
  cutefish-toolkit,
  icu,
  pcre2,
}:

let
  cu = import ../cutefish/mk.nix { inherit lib; };
in
stdenv.mkDerivation {
  pname = "cutefish-text-editor";
  version = cu.version "2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "text-editor";
    rev = "c17fab33f00335558a4375769642fb49c2f660ab";
    hash = "sha256-l6D6tiEtf3VAjkbC9eqJwVP0I6BzU/2Z+FyYQ+eD5nc=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    icu
    pcre2
  ];

  cmakeFlags = cu.cmakeFlags;

  meta = {
    inherit (cu) homepage platforms;
    description = "Plain-text editor for the Cutefish desktop";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-text-editor";
  };
}
