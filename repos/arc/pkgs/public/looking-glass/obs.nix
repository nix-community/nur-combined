{ stdenv, fetchpatch, looking-glass-client, looking-glass-host, lib, libbfd, obs-studio, libGLU, cmake, pkg-config, enableThreading ? false }: let
  namedPatches = import ./patches.nix { inherit fetchpatch; };
in stdenv.mkDerivation {
  pname = "looking-glass-obs";
  inherit (looking-glass-host) src version;
  inherit (looking-glass-client) meta;

  NIX_CFLAGS_COMPILE = looking-glass-client.NIX_CFLAGS_COMPILE or "-mavx"; # TODO fix?

  patches = with namedPatches; [
    singlethread
  ];

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ libbfd obs-studio libGLU ];

  cmakeFlags = [
    "-DOPTIMIZE_FOR_NATIVE=OFF"
    "-DENABLE_THREADS=${if enableThreading then "ON" else "OFF"}"
    "../obs"
  ];

  passthru = {
    inherit namedPatches;
  };
}
