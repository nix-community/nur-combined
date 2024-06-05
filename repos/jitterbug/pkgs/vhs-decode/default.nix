{ lib
, python3Packages
, fetchFromGitHub
, symlinkJoin
, ffmpeg
, stdenv
, cmake
, pkg-config
, qt5
, qt6
, qwt
, fftw
, useQt6 ? false
, enableHiFiGui ? true
, ...
}:
let
  qt = if useQt6 then qt6 else qt5;
  pyqt = if useQt6 then python3Packages.pyqt6 else python3Packages.pyqt5;
  qtVersion = if useQt6 then "6" else "5";

  # we need a valid version for SETUPTOOLS_SCM
  version = "0.2.7";
  rev = "76a0cca8335b94c7b6319eb21cd21a59fb433543";

  src = fetchFromGitHub {
    inherit rev;
    owner = "oyvindln";
    repo = "vhs-decode";
    sha256 = "sha256-DlrEcaD9XsdkhmRBxEy1vtI9gbRY9dmh6rDd7d2GAbc=";
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
    ++ lib.optionals enableHiFiGui (with qt; [ qtbase qtwayland wrapQtAppsHook ]);

    nativeBuildInputs = with python3Packages; [
      setuptools_scm
    ];

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
      ] ++ lib.optionals enableHiFiGui [ pyqt ];

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
      qwt
      ffmpeg
      fftw
      qt.qtbase
      qt.qtwayland
      qt.wrapQtAppsHook
    ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DBUILD_PYTHON=false"
      "-DUSE_QT_VERSION=${qtVersion}"
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
