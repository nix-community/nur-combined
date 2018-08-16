{ stdenv, runCommandNoCC, lib }:

let
  version = "2.1dtz-mux-ae88db0";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/d5c3c22ab6cd103129554e64f7b6d2c978f1aad2a52d7cae3b991d7602786538.nar.xz";
    narHash = "sha256:0icasih5cqrvl7ps3r4lclxri2bmp3mfzfvr4gqslmr9a8iq487k";
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
