{ stdenv, lib
, fetchFromGitHub
, fetchpatch, runCommand, buildPackages
, looking-glass-client
, cmake, pkg-config
, libbfd, libGLU, libX11
, libxcb, libXfixes
, nvidia-capture-sdk
, enableNvfbc ? false
, optimizeForArch ? null
}: with lib; let
  namedPatches = import ./patches.nix { inherit fetchpatch; };
  # TODO: this seems like a problem mingw or cmake should handle?
  windres = buildPackages.writeShellScriptBin "windres" ''
    exec ${stdenv.cc.targetPrefix}windres \
      --preprocessor "$CC -E -xc-header -DRC_INVOKED" \
      "$@"
  '';
in stdenv.mkDerivation rec {
  pname = "looking-glass-host";
  version = "2021-07-24";
  src = fetchFromGitHub {
    owner = "gnif";
    repo = "LookingGlass";
    rev = "181b165a4ba45eeedcd8d908b3e786b6ff7a1a35";
    sha256 = "180g44jym96hzmw0a9wj0gss9q4fr4402ir6v0csarz8aqc7rq8z";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = optionals stdenv.isLinux [
    libbfd libGLU libX11
    libxcb libXfixes
  ];

  patches = with namedPatches; [
    nvfbc-pointerthread
    nvfbc-framesize nvfbc-scale
  ];

  makeFlags = [
    "VERBOSE=1"
  ];
  cmakeFlags = [
    "-DVERSION=${version}"
    "-DOPTIMIZE_FOR_NATIVE=${if optimizeForArch == null then "OFF" else optimizeForArch}"
    "../host"
  ] ++ optionals stdenv.hostPlatform.isWindows ([
    "-DCMAKE_RC_COMPILER=${windres}/bin/windres"
  ] ++ optionals enableNvfbc [
    "-DUSE_NVFBC=ON"
    "-DNVFBC_SDK=${nvidia-capture-sdk.sdk}"
  ]);

  hardeningDisable = [ "all" ];

  meta = looking-glass-client.meta or { } // {
    platforms = with platforms; linux ++ windows;
  };

  passthru = {
    inherit namedPatches;
  };
}
