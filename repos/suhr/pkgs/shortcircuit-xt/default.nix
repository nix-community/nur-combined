{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  alsa-lib,
  fontconfig,
  freetype,
  gtkmm3,
  libjack2,
  clap,
  libX11,
  libXcursor,
  libXext,
  libXinerama,
  libXrandr
}:

let
  revision = "10a87df5058e53ec49704e94179f4f865e5fc0ee";
  revShort = builtins.substring 0 7 revision;
  vst3 = fetchFromGitHub {
    owner = "steinbergmedia";
    repo = "vst3sdk";
    rev = "v3.7.6_build_18";
    fetchSubmodules = true;
    hash = "sha256-jfh+iP5rqov8q++IyG4FXlYKs4PQtFjCwCP6xou8N0E=";
  };
  rtaudio = fetchFromGitHub {
    owner = "thestk";
    repo = "rtaudio";
    rev = "6.0.1";
    hash = "sha256-Acsxbnl+V+Y4mKC1gD11n0m03E96HMK+oEY/YV7rlIY=";
  };
  rtmidi = fetchFromGitHub {
    owner = "thestk";
    repo = "rtmidi";
    rev = "6.0.0";
    hash = "sha256-QuUeFx8rPpe0+exB3chT6dUceDa/7ygVy+cQYykq7e0=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "shortcircuit-xt";
  version = "2026-01-01";

  src = fetchFromGitHub {
    owner = "surge-synthesizer";
    repo = "shortcircuit-xt";
    rev = revision;
    fetchSubmodules = true;
    hash = "sha256-Nu5oXCXMm9u7ZJ3gesYrksULr9yYAYXeVObtDl5mM8w=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    fontconfig
    freetype
    libjack2
    clap
    gtkmm3
    libX11
    libXcursor
    libXext
    libXinerama
    libXrandr
  ];

  # see https://github.com/NixOS/nixpkgs/pull/149487#issuecomment-991747333
  postPatch = ''
    export SOURCE_DATE_EPOCH=1764277200
    export XDG_DOCUMENTS_DIR=$(mktemp -d)
    printf "SST_VERSION_INFO\n${revShort}\n-no-tag-\nmain\nNix-${finalAttrs.version}" > BUILD_VERSION
    substituteInPlace libs/CMakeLists.txt --replace-fail "CLAP_WRAPPER_DOWNLOAD_DEPENDENCIES TRUE" "CLAP_WRAPPER_DOWNLOAD_DEPENDENCIES FALSE"
  '';

  enableParallelBuilding = true;

  cmakeFlags = [
    "-DVST3_SDK_ROOT=${vst3}"
    "-DRTAUDIO_SDK_ROOT=${rtaudio}"
    "-DRTMIDI_SDK_ROOT=${rtmidi}"
  ];

  CXXFLAGS = [
    "-Wno-format-security"
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

  meta = with lib; {
    description = "A successor to Shortcircuit 1 & 2";
    homepage = "https://github.com/surge-synthesizer/shortcircuit-xt";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ maintainers.suhr ];
  };
})
