{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-be78ada";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/0ace7ddff4f20c16cf2ec8fb771f2229ba1a4752ddfe9e26121197a7bba9ed50.nar.xz";
    narHash = "sha256:0b88l5r8n2bi3qp305z7d25dikfm9lj0zlqrpkn261ymyw7xhl8c";
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
