{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-c68d83e";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/d84d59cf3b2f1a129c562b7942a0c8fcde464009464795f216e6cd8360364b96.nar.xz";
    narHash = "sha256:04q3bqag3yv620bmxinblb8i79d0nifwp9nrza5h1yrcc6dzp6b6";
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
