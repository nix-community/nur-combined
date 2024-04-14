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
, enableHiFiGui ? true
, ...
}:
let
  # we need a valid version for SETUPTOOLS_SCM
  version = "0.2.5";
  rev = "8f30d2d3e648a833c139b9baa5239e917e6ca673";

  src = fetchFromGitHub {
    inherit rev;
    owner = "oyvindln";
    repo = "vhs-decode";
    sha256 = "sha256-NnBAOh+XXZgwTkGAxToF2gElq9oBrikctdK/WwzlZxo=";
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
    ]
    ++ lib.optionals enableHiFiGui [ qt6.qtbase ]
    ++ lib.optionals (stdenv.isLinux && enableHiFiGui) [ qt6.qtwayland ];

    nativeBuildInputs = with python3Packages; [
      setuptools_scm
    ] ++ lib.optionals enableHiFiGui [ qt6.wrapQtAppsHook ];

    propagatedBuildInputs = with python3Packages;
      [
        cython
        numpy
        jupyter
        numba
        pandas
        scipy
        matplotlib
        soundfile
        sounddevice
        samplerate
      ] ++ lib.optionals enableHiFiGui [ pyqt6 ];

    postFixup = lib.optionalString enableHiFiGui ''
      wrapQtApp $out/bin/hifi-decode
    '';
  };

  vhs-decode-tools = stdenv.mkDerivation {
    inherit src version;
    pname = "vhs-decode-tools";

    nativeBuildInputs = [
      cmake
      pkg-config
    ];

    buildInputs = [
      qt6.qtbase
      qt6.qtwayland
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
