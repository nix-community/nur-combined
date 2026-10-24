{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  cmake,
  ninja,
  gtk3,
}:

let
  cu = import ../cutefish/mk.nix { inherit lib; };
in
stdenvNoCC.mkDerivation {
  pname = "cutefish-icons";
  version = cu.version "2026-10-23";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "icons";
    rev = "863d156cbef6be7bc2eb7c4453800df416bd73ea";
    hash = "sha256-Yd+bd2ACS9TAsakFjAoCP54hs7N0i0SQaslWztjamwo=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    gtk3
  ];

  cmakeFlags = cu.cmakeFlags;

  # The Colloid-based theme ships a handful of symlinks whose targets are not
  # in the tree. Drop them so the package can be installed.
  preFixup = ''
    find "$out" -xtype l -delete
  '';

  meta = {
    inherit (cu) homepage platforms;
    description = "Cutefish icon theme, based on Colloid";
    license = lib.licenses.gpl3Plus;
  };
}
