{
  stdenv,
  lib,
  fetchFromGitHub,
  gitUpdater,
  cmake,
  pkg-config,
  alsa-lib,
  freetype,
  libjack2,
  lv2,
  libX11,
  libXcursor,
  libXext,
  libXinerama,
  libXrandr,

  buildVST3 ? true,
  buildLV2 ? true,
  buildCLAP ? true,
  buildStandalone ? true,
}:
let
  inherit (lib) optional optionalString;

  flag = bool: if bool then "TRUE" else "FALSE";

  rev-prefix = "release_xt_";
in
stdenv.mkDerivation rec {
  pname = "surge-XT";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "surge-synthesizer";
    repo = "surge";
    tag = "${rev-prefix}${version}";
    fetchSubmodules = true;
    hash = "sha256-4b0H3ZioiXFc4KCeQReobwQZJBl6Ep2/8JlRIwvq/hQ=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    freetype
    libjack2
    libX11
    libXcursor
    libXext
    libXinerama
    libXrandr
  ]
  ++ optional buildLV2 [ lv2 ];

  enableParallelBuilding = true;

  cmakeFlags = [
    "-DSURGE_SKIP_STANDALONE=${flag (!buildStandalone)}"
    "-DSURGE_SKIP_VST3=${flag (!buildVST3)}"
    "-DSURGE_BUILD_LV2=${flag buildLV2}"
    "-DSURGE_BUILD_CLAP=${flag buildCLAP}"
  ];

  # JUCE dlopen's these at runtime, crashes without them
  NIX_LDFLAGS = (
    toString [
      "-lX11"
      "-lXext"
      "-lXcursor"
      "-lXinerama"
      "-lXrandr"
    ]
  );

  patches = [ ./clap-option.diff ];

  postPatch = ''
    # see https://github.com/NixOS/nixpkgs/pull/149487#issuecomment-991747333
    export XDG_DOCUMENTS_DIR=$(mktemp -d)
    substituteInPlace CMakeLists.txt --replace-fail \
      'cmake_minimum_required(VERSION 3.15)' \
      'cmake_minimum_required(VERSION 3.30)'
    substituteInPlace libs/libsamplerate/CMakeLists.txt --replace-fail \
      'cmake_minimum_required(VERSION 3.1..3.18)' \
      'cmake_minimum_required(VERSION 3.30)'
  '';

  passthru.updateScript = gitUpdater {
    inherit rev-prefix;
  };

  meta = with lib; {
    description = "LV2 & VST3 synthesizer plug-in (previously released as Vember Audio Surge)";
    homepage = "https://surge-synthesizer.github.io";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [
      magnetophon
      orivej
      mrtnvgr
    ];
  };
}
