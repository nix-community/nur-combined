{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-c68d83e";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/769664c8c0560f9a92ff352f25313445964d3ad0a8179ba74abe6127d884d911.nar.xz";
    narHash = "sha256:1rb8635wfpiyi6l060ih2wxpvpjkk0cdhh5vdg9jbynhbpfs123d";
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
