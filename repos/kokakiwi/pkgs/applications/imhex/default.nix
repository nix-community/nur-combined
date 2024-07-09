{ lib, stdenv

, fetchFromGitHub
, autoPatchelfHook

, cmake
, llvm
, python3
, perl
, pkg-config
, rsync

, mbedtls
, gtk3
, capstone
, dbus
, libGL
, libGLU
, glfw3
, file
, jansson
, curl
, fmt_8
, nlohmann_json
, yara

, libxkbcommon
, libdecor
, wayland
}:
let
  glfw3-patched = glfw3.overrideAttrs (prev: {
    postPatch = lib.optionalString stdenv.isLinux ''
      substituteInPlace src/wl_init.c \
        --replace-fail "libxkbcommon.so.0" "${lib.getLib libxkbcommon}/lib/libxkbcommon.so.0" \
        --replace-fail "libdecor-0.so.0" "${lib.getLib libdecor}/lib/libdecor-0.so.0" \
        --replace-fail "libwayland-client.so.0" "${lib.getLib wayland}/lib/libwayland-client.so.0" \
        --replace-fail "libwayland-cursor.so.0" "${lib.getLib wayland}/lib/libwayland-cursor.so.0" \
        --replace-fail "libwayland-egl.so.1" "${lib.getLib wayland}/lib/libwayland-egl.so.1"
    '';
  });
in stdenv.mkDerivation rec {
  pname = "imhex";
  version = "1.35.4";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "WerWolv";
    repo = "ImHex";
    rev = "refs/tags/v${version}";
    hash = "sha256-6QpmFkSMQpGlEzo7BHZn20c+q8CTDUB4yO87wMU5JT4=";
  };

  patterns = fetchFromGitHub {
    owner = "WerWolv";
    repo = "ImHex-Patterns";
    rev = "ImHex-v${version}";
    hash = "sha256-7ch2KXkbkdRAvo3HyErWcth3kG4bzYvp9I5GZSsb/BQ=";
  };

  outputs = [ "out" "sdk" ];

  nativeBuildInputs = [
    autoPatchelfHook
    cmake
    llvm
    python3
    perl
    pkg-config
    rsync
  ];

  buildInputs = [
    capstone
    curl
    dbus
    file
    fmt_8
    glfw3-patched
    gtk3
    jansson
    libGLU
    mbedtls
    nlohmann_json
    yara
  ];

  cmakeFlags = [
    "-DIMHEX_OFFLINE_BUILD=ON"
    "-DUSE_SYSTEM_CAPSTONE=ON"
    "-DUSE_SYSTEM_CURL=ON"
    "-DUSE_SYSTEM_FMT=ON"
    "-DUSE_SYSTEM_LLVM=ON"
    "-DUSE_SYSTEM_NLOHMANN_JSON=ON"
    "-DUSE_SYSTEM_YARA=ON"
  ];

  autoPatchelfIgnoreMissingDeps = [
    "*.hexpluglib"
  ];
  appendRunpaths = [
    (lib.makeLibraryPath [ libGL ])
    "${placeholder "out"}/lib/imhex/plugins"
  ];

  # rsync is used here so we can not copy the _schema.json files
  postInstall = ''
    mkdir -p $out/share/imhex
    rsync -av --exclude="*_schema.json" $patterns/{constants,encodings,includes,magic,patterns} $out/share/imhex

    mv $out/share/imhex/sdk $sdk
  '';

  meta = with lib; {
    description = "Hex Editor for Reverse Engineers, Programmers and people who value their retinas when working at 3 AM";
    homepage = "https://github.com/WerWolv/ImHex";
    license = with licenses; [ gpl2Only ];
    platforms = platforms.linux;
  };
}
