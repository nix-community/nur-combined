{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-6fb06a5";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/6043f3806e895919e15c5b7812a8ccd851090794566a7d01b260395a81512551.nar.xz";
    narHash = "sha256:1k6315saf5w2xdhc2136xirl1dz940xqi6f85aqlksdq3nzdzsg5";
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
