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
}:

let
  cu = import ../cutefish/mk.nix { inherit lib; };
in
stdenv.mkDerivation {
  pname = "cutefish-system-monitor";
  version = cu.version "2026-10-20";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "system-monitor";
    rev = "0ddafa412a7e2959a652846f80e867dc253cff26";
    hash = "sha256-ySU7vWdAgvhRkTItQvFh/Buw8HjmQvPqL9Yr1D4GMmA=";
  };

  postPatch = ''
    substituteInPlace src/gpureader.cpp \
      --replace-fail '{"/usr/share/misc/pci.ids", "/usr/share/hwdata/pci.ids"}' \
        '{"/run/current-system/sw/share/hwdata/pci.ids", "/usr/share/misc/pci.ids", "/usr/share/hwdata/pci.ids"}'
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    icu
  ];

  cmakeFlags = cu.cmakeFlags;

  meta = {
    inherit (cu) homepage platforms;
    description = "System monitor for the Cutefish desktop";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-system-monitor";
  };
}
