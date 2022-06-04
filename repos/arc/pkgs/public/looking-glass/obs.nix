{ stdenv
, fetchpatch
, looking-glass-client, looking-glass-host
, lib
, libbfd
, obs-studio, libGLU
, cmake, pkg-config
, enableThreading ? false
, optimizeForArch ? null
}: let
  namedPatches = import ./patches.nix { inherit fetchpatch; };
in stdenv.mkDerivation {
  pname = "looking-glass-obs";
  inherit (looking-glass-host) src version;
  inherit (looking-glass-client) meta;

  NIX_CFLAGS_COMPILE = looking-glass-client.NIX_CFLAGS_COMPILE or "-mavx"; # TODO fix?

  patches = with namedPatches; [
    singlethread cmake-obs-installdir
  ];

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ libbfd obs-studio libGLU ];

  cmakeFlags = [
    "-DOPTIMIZE_FOR_NATIVE=${if optimizeForArch == null then "OFF" else optimizeForArch}"
    "-DENABLE_THREADS=${if enableThreading then "ON" else "OFF"}"
    "../obs"
  ];

  hardeningDisable = [ "all" ];

  passthru = {
    inherit namedPatches;
  };
}
