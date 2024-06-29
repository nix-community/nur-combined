{ lib, stdenv

, fetchFromGitHub

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
, libGLU
, glfw3
, file
, jansson
, curl
, fmt_8
, nlohmann_json
, yara
}:
stdenv.mkDerivation rec {
  pname = "imhex";
  version = "1.35.1";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "WerWolv";
    repo = "ImHex";
    rev = "v${version}";
    hash = "sha256-kCa2hS9RA5MBJg8tU3yZdwuvlyHYJ8AiI0+jA/GECZ0=";
  };

  patterns = fetchFromGitHub {
    owner = "WerWolv";
    repo = "ImHex-Patterns";
    rev = "ImHex-v${version}";
    hash = "sha256-h86qoFMSP9ehsXJXOccUK9Mfqe+DVObfSRT4TCtK0rY=";
  };

  outputs = [ "out" "sdk" ];

  nativeBuildInputs = [ cmake llvm python3 perl pkg-config rsync ];

  buildInputs = [
    capstone
    curl
    dbus
    file
    fmt_8
    glfw3
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
