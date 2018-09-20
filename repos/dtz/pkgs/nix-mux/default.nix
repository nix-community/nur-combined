{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-c68d83e";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/98b1bb8081ab85a3238e69bd22904663070e791c232b2f0ab0f710bb5c9c20d0.nar.xz";
    narHash = "sha256:0mg1v2ng5qayjfk8gc4n67yqrjhqy4hd97lx998ns4i6jb43vfvc";
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
