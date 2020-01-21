{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-13e4753";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/d3263e221f74a3c8929a698785f513f60d1ceb3f2984173f0c9f879dff12e6f4.nar.xz";
    narHash = "sha256:1l6p60rkxb25ha6vzgq2id090cdnxgdix9qplrk3spj3zjlqk9vp";
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
