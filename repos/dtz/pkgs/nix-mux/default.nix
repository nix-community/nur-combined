{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-aacfddb";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/c769cac329f45f9f1c5e82166597439348a9192fea0f11322221a2fe96714317.nar.xz";
    narHash = "sha256:1svhkc74986hwbbv7avlkcfwklprzfgmngx9nlwc896qpq7qz8qm";
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
