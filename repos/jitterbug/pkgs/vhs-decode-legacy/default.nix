{
  maintainers,
  lib,
  fetchFromGitHub,
  symlinkJoin,
  python3Packages,
  rustPlatform,
  qwt-qt6,
  tbc-tools,
  vhs-decode,
}:
let
  pname = "vhs-decode-legacy";
  version = "0.3.8";

  rev = version;
  hash = "sha256-j//BBL8OrT3KxOonatWQ9o8VdE/6bVX2y6Kte55kGwU=";
  cargoHash = "sha256-fKAqjvx4Gqa426OyR2qEPXUPEneXGOT1GqOMFDol0Zc=";

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "oyvindln";
    repo = "vhs-decode";
  };
in
symlinkJoin {
  inherit pname version;

  paths = [
    (tbc-tools.overrideAttrs (
      finalAttrs: prevAttrs: {
        inherit pname version src;

        buildInputs = prevAttrs.buildInputs ++ [
          qwt-qt6
        ];

        cmakeFlags = prevAttrs.cmakeFlags ++ [
          (lib.cmakeBool "BUILD_PYTHON" false)
          (lib.cmakeFeature "USE_QT_VERSION" "6")
        ];
      }
    ))

    (vhs-decode.overridePythonAttrs (prevAttrs: {
      inherit pname version src;

      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit pname version src;
        hash = cargoHash;
      };

      propagatedBuildInputs = [
        python3Packages.cython
        python3Packages.jupyter
        python3Packages.matplotlib
        python3Packages.numba
        python3Packages.numpy
        python3Packages.pandas
        python3Packages.scipy
        python3Packages.soundfile
        python3Packages.sounddevice
        python3Packages.samplerate
        python3Packages.soxr
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
    }))
  ];

  meta = {
    inherit maintainers;
    description = "Software Decoder for raw rf captures of laserdisc, vhs and other analog video formats.";
    homepage = "https://github.com/oyvindln/vhs-decode";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "vhs-decode";
  };
}
