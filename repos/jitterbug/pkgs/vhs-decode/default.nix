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
  # we need a valid version for SETUPTOOLS_SCM
  version = "0.2.4";
  rev = "d46caf09128e4a98281100c6a6d28f09139d9ae3";

  src = fetchFromGitHub {
    inherit rev;
    owner = "oyvindln";
    repo = "vhs-decode";
    sha256 = "sha256-sjjN42ViIPCthbIM3RhjQirBXErKPCGFXtLd9OgD8QE=";
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
      pyhht
      samplerate
    ];

    prePatch = ''
      # causes FileExistsError as pyproject.toml also defines projects.scripts
      substituteInPlace "setup.py" \
        --replace "scripts=[" "__disabled_scrips=["

      substituteInPlace "pyproject.toml" \
        --replace ", \"static-ffmpeg\"" ""

      substituteInPlace "pyproject.toml" \
        --replace "numba>=0.48" "numba"
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
  name = "vhs-decode";
  version = rev;

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
