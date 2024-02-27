{ lib
, python3Packages
, fetchFromGitHub
, symlinkJoin
, ffmpeg
, stdenv
, cmake
, pkg-config
, qt6
, qwt
, fftw
, ...
}:
let
  # we need a valid version for SETUPTOOLS_SCM
  version = "0.2.5";
  rev = "e21da865a424dbf2288c827435fba50b2a04a7f8";

  src = fetchFromGitHub {
    inherit rev;
    owner = "oyvindln";
    repo = "vhs-decode";
    sha256 = "sha256-mYMnHG1mPIz/YDrnwhHbSr8TI3W6sJXHLV8em8rV7ao=";
  };

  py-vhs-decode = python3Packages.buildPythonApplication {
    inherit src version;
    pname = "py-vhs-decode";
    format = "setuptools";
    doCheck = false;

    # workaround for no .git
    SETUPTOOLS_SCM_PRETEND_VERSION = version;

    buildInputs = [
      ffmpeg
    ];

    nativeBuildInputs = with python3Packages; [
      setuptools_scm
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
      samplerate
    ];
  };

  vhs-decode-tools = stdenv.mkDerivation {
    inherit src version;
    pname = "vhs-decode-tools";

    nativeBuildInputs = [
      cmake
      pkg-config
    ];

    buildInputs = [
      qt6.qttools
      qt6.wrapQtAppsHook
      qwt
      ffmpeg
      fftw
    ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DUSE_QT_VERSION=6"
      "-DBUILD_PYTHON=false"
    ];
  };
in
symlinkJoin {
  name = "vhs-decode";
  version = rev;

  paths = [
    py-vhs-decode
    vhs-decode-tools
  ];

  meta = with lib; {
    description = "Software Decoder for raw rf captures of laserdisc, vhs and other analog video formats.";
    license = licenses.gpl3;
    maintainers = [ "JuniorIsAJitterbug" ];
    homepage = "https://github.com/oyvindln/vhs-decode";
  };
}
