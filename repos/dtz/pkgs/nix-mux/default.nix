{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-05d9150";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/22c64284cc395069e09a365282bce63b75ad0cdaa67922523a4f38d03f7abe89.nar.xz";
    narHash = "sha256:0asjan31i74g327j8yal7yg761sz13bg2qhv627ss14q7chbsm7b";
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
