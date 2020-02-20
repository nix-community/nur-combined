{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-1763993";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/b5ec1edf9ea0e47b81c49b6b296b968a58e583263182a6519c65269a6303f6ff.nar.xz";
    narHash = "sha256:13w8d2hfhd4g6ap9mwhv3064zdhif89x92vw7w21zs1jzkhv496y";
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
