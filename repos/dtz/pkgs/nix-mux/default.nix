{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-3d334bc";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/1f31ceb41c865988392f4fb9957666b3e980ea7ee05035b454a39d5b8210a1b9.nar.xz";
    narHash = "sha256:1d7asn5iv6ms0va4f90a5iilwaivrivjxmw8r9gz15bdhbgwvzj1";
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
