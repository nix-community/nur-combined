{
  lib,
  stdenv,
  python3Packages,
  ffmpeg,
  qt6,
  ...
}:
python3Packages.buildPythonPackage {
  pname = "vhs-decode-py";

  pyproject = true;

  build-system = [
    python3Packages.setuptools
    python3Packages.setuptools-scm
    python3Packages.setuptools-rust
  ];

  buildInputs = [
    ffmpeg
    qt6.qtbase
    qt6.wrapQtAppsHook
  ]
  ++ lib.optional stdenv.isLinux [
    qt6.qtwayland
  ];

  propagatedBuildInputs = [
    python3Packages.numpy
    python3Packages.numba
    python3Packages.scipy
    python3Packages.soxr
    python3Packages.cython
    python3Packages.soundfile
    python3Packages.sounddevice
    python3Packages.matplotlib
    python3Packages.noisereduce
    python3Packages.setproctitle
    python3Packages.pyqt6
  ];

  postPatch = ''
    # remove static-ffmpeg dep
    substituteInPlace pyproject.toml \
      --replace-fail '"static-ffmpeg", ' ""

    # filter-tune module needs adding
    substituteInPlace setup.py \
      --replace-fail "packages=[" 'packages=["filter_tune",'
  '';

  postFixup = ''
    wrapQtApp $out/bin/hifi-decode
    wrapQtApp $out/bin/filter-tune
  '';

  pythonImportsCheck = [
    "lddecode"
    "vhsdecode"
    "vhsdecode.hifi"
    "cvbsdecode"
    "filter_tune.filter_tune"
    "vhsd_rust"
  ];
}
