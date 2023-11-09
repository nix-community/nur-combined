{ lib, libsForQt5 }: libsForQt5.callPackage ({ mkDerivation, qmake, fetchFromGitLab }: let
  pname = "EDFbrowser";
  version = "2.05";
in mkDerivation {
  inherit pname version;

  src = fetchFromGitLab {
    owner = "Teuniz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-ISJAWqsBYm65fiv9ju0TD2idUkmwpq21M50rNhOk5ys=";
  };

  patches = [
    ./prefix.patch
  ];

  nativeBuildInputs = [
    qmake
  ];

  meta = {
    platforms = lib.platforms.linux;
    mainProgram = "edfbrowser";
  };
}) { }
