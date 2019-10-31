{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-2273134";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/2a6d24b9d5468b88f35071e9b7d71687c6510d83faad4d88e06fca1beffe71a7.nar.xz";
    narHash = "sha256:0sk5z1x79qi5bfkq3qm7hzvfcxprccl7r7hi64n5zv9zdd9z906y";
  };

  bootstrapFiles = {
    # TODO: better way of grabbing this
    busybox = stdenv.bootstrapTools.builder;

    tarball = nix-mux-tarball;
  };

  unpack = import ./unpack.nix {
    name = "nix-${version}";
    inherit (stdenv.hostPlatform) system;
    inherit bootstrapFiles;
  };

  meta = with lib; {
    description = "Nix All-in-One! (multiplexed)";
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.lgpl2Plus;
    homepage = https://github.com/allvm/allvm-tools;
  };
in
  unpack // { inherit meta; }
