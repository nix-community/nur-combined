{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-75668ad";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/3918360fdd9032133506a425f6bc3641267ba6604b248301cc7616e181a033d3.nar.xz";
    narHash = "sha256:1sacvdpc7qdh7jif5n8zchgkyp2027sxq5ggysrh1biv0pxcfxj0";
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
