{ stdenv, runCommandNoCC, lib }:

let
  version = "2.1dtz-mux-75d7d58";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/53cc5229ae495cdd6973d4016efb13bc3ae7efa9a0c7c1bf9a4da7fae94ed2bd.nar.xz";
    narHash = "sha256:02qsvv9vgwqifd4w1nfq2cx6vd87w9rnpbkbmb5rzbfapy7pcqdy";
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
