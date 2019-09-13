{ stdenv, runCommandNoCC, lib }:

let
  version = "2.4dtz-mux-ee2e17b";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/2356772b7ed71d2b96b08796bafada6e3fe86b7b5b3b2b4ee665d128180db85d.nar.xz";
    narHash = "sha256:1np0gsplblbvvw9x32qg7nkwgd46910ykfqfsrpzmhf67z6nxrlp";
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
