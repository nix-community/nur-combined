{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-28cb9c6";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/72694cb5b64d4f2ff8fbc9d5aa40b5b819b702743dd7536ed7dbc30688b02661.nar.xz";
    narHash = "sha256:0lfp7hzq43c3gvvq6qb21q9mqjfdmwpgcmysnsad51cnvnac5wgs";
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
