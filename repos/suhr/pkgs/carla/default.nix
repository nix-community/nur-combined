{ stdenv, fetchFromGitHub
, pkgconfig
, python3, liblo, file, qt5, libjack2, libsndfile
}:

let
  pythonEnv = python3.withPackages(ps: with ps; [ pyliblo pyqt5 ]);
in
  stdenv.mkDerivation rec {
    name = "carla-${version}";
    version = "1.9.12";

    src = fetchFromGitHub {
      owner = "falkTX";
      repo = "Carla";
      rev = "v${version}";
      sha256 = "0hk3g0dhg91cbx19agvcy6idc0w4hfy1rg39yj3k82rxvghr4126";
    };

    buildInputs = [
      pythonEnv
      liblo
      file
      qt5.qtbase
      libjack2
      libsndfile
    ];

    nativeBuildInputs = [
      pkgconfig
    ];

    pyrcc5 = "PYRCC5=${pythonEnv}/bin/pyrcc5";
    pyuic5 = "PYUIC5=${pythonEnv}/bin/pyuic5";

    buildPhase = ''
      make ${pyrcc5} ${pyuic5} PREFIX=$out
    '';

    installPhase = ''
      make ${pyrcc5} ${pyuic5} install PREFIX=$out
    '';

    meta = with stdenv.lib; {
      description = "Audio plugin host";
      homepage = "https://github.com/falkTX/Carla";
      license = licenses.gpl2;
      platforms = platforms.linux;
      maintainers = [ ];
    };
  }
