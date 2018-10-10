{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-b8d4139";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/61e278c177aad7f62b63a41da7345a7c318743aafd21f7588897f37cad28dee3.nar.xz";
    narHash = "sha256:08bkxc5974j9kywlkk7bi45vac8dcnfglscpvfgj5fd53lywqrlz";
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
