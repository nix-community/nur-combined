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
stdenv.mkDerivation (finalAttrs: {
  pname = "imhex";
  version = "1.37.4";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "WerWolv";
    repo = "ImHex";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uenwAaIjtBzrtiLdy6fh5TxtbWtUJbtybNOLP3+8blA=";
  };

  patterns = fetchFromGitHub {
    owner = "WerWolv";
    repo = "ImHex-Patterns";
    tag = "ImHex-v${finalAttrs.version}";
    hash = "sha256-2NgMYaG6+XKp0fIHAn3vAcoXXa3EF4HV01nI+t1IL1U=";
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
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
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
})
