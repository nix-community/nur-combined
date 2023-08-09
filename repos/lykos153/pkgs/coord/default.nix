{ stdenv
, fetchFromSourcehut
, python311
}:

stdenv.mkDerivation rec {
  name = "coord";
  version = "1.0";
  propagatedBuildInputs = [
    (python311.withPackages (pythonPackages: with pythonPackages; [
      pyqt6
    ]))
  ];
  src = fetchFromSourcehut {
    owner = "~geb";
    repo = "coord";
    rev = version;
    hash = "sha256-noEU8VXrFjhXd39R0Ps9m1/K2lt4fOXsjnNuVCDlknM=";
  };
  dontUnpack = true;
  installPhase = "install -Dm755 $src/coord $out/bin/coord";
}
