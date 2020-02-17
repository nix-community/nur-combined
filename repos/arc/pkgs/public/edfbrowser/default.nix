{ lib, libsForQt5 }: libsForQt5.callPackage ({ mkDerivation, qmake, fetchFromGitLab }: let
  pname = "EDFbrowser";
  version = "1.71";
in mkDerivation {
  inherit pname version;

  src = fetchFromGitLab {
    owner = "Teuniz";
    repo = pname;
    rev = "v${version}";
    sha256 = "0vis7an1hkmmil4sdsaiyva6af79qgvnq836chnai1kcprwd00aa";
  };

  patches = [
    ./prefix.patch
  ];

  nativeBuildInputs = [
    qmake
  ];

  meta = {
    platforms = lib.platforms.linux;
  };
}) { }
