{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-39e27cd";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/bfc025f67aa6e417bf82fa120feff05b51b40b7e6aa8121d5563c02534e5de83.nar.xz";
    narHash = "sha256:05a9x5p9byg177xvld930w03p0535nnnf8k8xskm72yrixh39mxz";
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
