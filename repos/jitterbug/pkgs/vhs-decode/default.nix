{ lib
, python3Packages
, fetchFromGitHub
, symlinkJoin
, ffmpeg
, pyhht
, stdenv
, cmake
, pkg-config
, qt5
, libsForQt5
, fftw
, ...
}:
let
  version = "de9f0d2d28bf2c2e792bb3b17c4cac3352f5b88f";

  src = fetchFromGitHub {
    owner = "oyvindln";
    repo = "vhs-decode";
    sha256 = "sha256-ZwMC1L3NGlk5ZnUbwEyBvNCizl7dCTmfKSq1g+zZor0=";
    rev = version;
  };

  py-vhs-decode = python3Packages.buildPythonApplication
    {
      pname = "py-vhs-decode";
      inherit src version;

      buildInputs = [
        ffmpeg
      ];

      propagatedBuildInputs = with python3Packages; [
        cython
        numpy
        jupyter
        numba
        pandas
        scipy
        matplotlib
        soundfile
        pyhht
        samplerate
      ];

      prePatch = ''
        substituteInPlace "pyproject.toml" \
          --replace ", \"static-ffmpeg\"" ""

        substituteInPlace "pyproject.toml" \
          --replace "numba>=0.48" "numba"
      '';

      doCheck = false;
    };

  vhs-decode-tools = stdenv.mkDerivation {
    pname = "vhs-decode-tools";
    inherit src version;

    nativeBuildInputs = [
      cmake
      pkg-config
    ];

    buildInputs = [
      qt5.qttools
      qt5.wrapQtAppsHook
      libsForQt5.qwt
      ffmpeg
      fftw
    ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DUSE_QT_VERSION=5"
      "-DBUILD_PYTHON=false"
    ];
  };
in
symlinkJoin {
  inherit version;
  name = "vhs-decode";

  paths = [
    py-vhs-decode
    vhs-decode-tools
  ];

  meta = with lib; {
    description = "Software Decoder for raw rf captures of laserdisc, vhs and other analog video formats";
    license = licenses.gpl3;
    maintainers = [ "JuniorIsAJitterbug" ];
    homepage = "https://github.com/oyvindln/vhs-decode";
  };
}
