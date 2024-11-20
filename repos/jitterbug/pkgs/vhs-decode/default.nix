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
  version = "0.3.0";
  rev = "4b3d2ebd55ee4ac178b8b37540f7bbf48a7c9a45";

  src = fetchFromGitHub {
    inherit rev;
    owner = "oyvindln";
    repo = "vhs-decode";
    sha256 = "sha256-AJ/FAKrUt2qJbswcIhQ2z4WQvnNaC1SVBmGcJwA+GHw=";
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
