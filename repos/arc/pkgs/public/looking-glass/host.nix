{ stdenv, lib
, fetchFromGitHub
, fetchpatch
, looking-glass-client
, cmake, pkg-config
, libbfd, libGLU, libX11
, libxcb, libXfixes
, pipewire, glib
, nvidia-capture-sdk
, enableNvfbc ? false
, enablePipewire ? stdenv.hostPlatform.isLinux
, enableXcb ? stdenv.hostPlatform.isLinux
, enableBacktrace ? false
, optimizeForArch ? null
}: with lib; let
  namedPatches = import ./patches.nix { inherit fetchpatch; };
in stdenv.mkDerivation rec {
  pname = "looking-glass-host";
  version = "2024-11-14";
  src = fetchFromGitHub {
    owner = "gnif";
    repo = "LookingGlass";
    rev = "e25492a3a36f7e1fde6e3c3014620525a712a64a";
    sha256 = "sha256-DBmCJRlB7KzbWXZqKA0X4VTpe+DhhYG5uoxsblPXVzg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ] ++ optional stdenv.hostPlatform.isLinux pkg-config;
  buildInputs = optionals stdenv.hostPlatform.isLinux [
  ] ++ optionals enableXcb [
    libbfd libGLU libX11
    libxcb libXfixes
  ] ++ optionals enablePipewire [
    pipewire
    glib
  ];

  /*patches = with namedPatches; [
    nvfbc-pointerthread
    nvfbc-framesize nvfbc-scale
  ];*/

  preConfigure = ''
    echo $version > VERSION
    if [[ $version = 20??-??-?? ]]; then
      export SOURCE_DATE_EPOCH=$(date -d $version +%s)
    fi
  '';

  makeFlags = [
    "VERBOSE=1"
  ];
  cmakeDir = "../host";
  cmakeFlags = [
    "-DOPTIMIZE_FOR_NATIVE=${if optimizeForArch == null then "OFF" else optimizeForArch}"
    "-DENABLE_BACKTRACE=${if enableBacktrace then "ON" else "OFF"}"
  ] ++ optionals stdenv.hostPlatform.isLinux [
    "-DUSE_XCB=${if enableXcb then "ON" else "OFF"}"
    "-DUSE_PIPEWIRE=${if enablePipewire then "ON" else "OFF"}"
  ] ++ optionals enableNvfbc [
    "-DUSE_NVFBC=ON"
    "-DNVFBC_SDK=${nvidia-capture-sdk.sdk}"
  ];

  # glib G_DEFINE_AUTOPTR_CLEANUP_FUNC error: 'response' may be used uninitialized
  NIX_CFLAGS_COMPILE = optional enablePipewire "-Wno-maybe-uninitialized";

  hardeningDisable = [ "all" ];

  meta = looking-glass-client.meta or { } // {
    platforms = with platforms; linux ++ windows;
  };

  passthru = {
    inherit namedPatches;
  };
}
