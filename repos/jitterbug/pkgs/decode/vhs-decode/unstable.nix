{
  maintainers,
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  rustPlatform,
  rustc,
  cargo,
  ffmpeg,
  qt6,
  ...
}:
let
  pname = "vhs-decode-unstable";
  version = "0.3.9-unstable-2026-03-25";

  rev = "a6eeafdaedc277f34423b307990e0e59ab1715ef";
  hash = "sha256-nGp4QrS2kL5KNrMDGiQ7mQrYmXjXSSgnC6ydgEltohA=";
  cargoHash = "sha256-fKAqjvx4Gqa426OyR2qEPXUPEneXGOT1GqOMFDol0Zc=";

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "oyvindln";
    repo = "vhs-decode";
  };
in
python3Packages.buildPythonPackage {
  inherit pname version src;

  pyproject = true;

  SETUPTOOLS_SCM_PRETEND_VERSION = (
    (lib.strings.removeSuffix "-unstable" (lib.strings.getName version))
    + "+"
    + (builtins.substring 0 7 rev)
  );

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = cargoHash;
  };

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
    python3Packages.cython
    python3Packages.matplotlib
    python3Packages.noisereduce
    python3Packages.numba
    python3Packages.numpy
    python3Packages.scipy
    python3Packages.setproctitle
    python3Packages.sounddevice
    python3Packages.soundfile
    python3Packages.soxr

    python3Packages.pyqt6
  ];

  nativeBuildInputs = [
    rustc
    cargo
    rustPlatform.cargoSetupHook
  ];

  postPatch = ''
    # remove static-ffmpeg dep
    substituteInPlace pyproject.toml \
      --replace-fail '"static-ffmpeg",' ""

    # fix duplicate script
    substituteInPlace setup.py \
      --replace-fail '"decode-launcher",' ""
  '';

  postFixup = ''
    wrapQtApp $out/bin/hifi-decode
    wrapQtApp $out/bin/filter-tune
    wrapQtApp $out/bin/decode-launcher
  '';

  pythonImportsCheck = [
    "lddecode"
    "vhsdecode"
    "vhsdecode.hifi"
    "vhsdecode.decode_launcher"
    "cvbsdecode"
    "filter_tune.filter_tune"
    "vhsd_rust"
  ];

  meta = {
    inherit maintainers;
    description = "Software Decoder for raw rf captures of laserdisc, vhs and other analog video formats.";
    homepage = "https://github.com/oyvindln/vhs-decode";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainprogram = "vhs-decode";
  };
}
