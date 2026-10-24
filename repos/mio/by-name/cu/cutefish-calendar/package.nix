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
  libical,
  curl,
}:

let
  cu = import ../cutefish/mk.nix { inherit lib; };
in
stdenv.mkDerivation {
  pname = "cutefish-calendar";
  version = cu.version "2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "calendar";
    rev = "342ffb934dc10733b5367582b0b0dd87f8fed1bb";
    hash = "sha256-NTpjXxZvrel7QNQ5GATT9tOakqDuw+IxgL1enW9XhXI=";
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
    libical
    curl
  ];

  cmakeFlags = cu.cmakeFlags;

  meta = {
    inherit (cu) homepage platforms;
    description = "Calendar for the Cutefish desktop";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-calendar";
  };
}
