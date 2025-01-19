{ lib, stdenv

, fetchFromGitHub
, autoPatchelfHook

, cmake
, llvmPackages
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
, fmt
, nlohmann_json
, yara
}:
stdenv.mkDerivation rec {
  pname = "imhex";
  version = "1.36.2";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "WerWolv";
    repo = "ImHex";
    rev = "refs/tags/v${version}";
    hash = "sha256-e7ppx2MdtTPki/Q+1kWswHkFLNRcO0Y8+q9VzpgUoVE=";
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
    llvmPackages.llvm
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
    fmt
    glfw3
    gtk3
    jansson
    libGLU
    mbedtls
    nlohmann_json
    yara
  ];

  cmakeFlags = [
    (lib.cmakeBool "IMHEX_OFFLINE_BUILD" true)
    (lib.cmakeBool "IMHEX_COMPRESS_DEBUG_INFO" false) # avoids error: cannot compress debug sections (zstd not enabled)
    (lib.cmakeBool "USE_SYSTEM_CAPSTONE" true)
    (lib.cmakeBool "USE_SYSTEM_CURL" true)
    (lib.cmakeBool "USE_SYSTEM_FMT" true)
    (lib.cmakeBool "USE_SYSTEM_LLVM" true)
    (lib.cmakeBool "USE_SYSTEM_NLOHMANN_JSON" true)
    (lib.cmakeBool "USE_SYSTEM_YARA" true)
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
