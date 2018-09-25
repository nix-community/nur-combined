{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-d2a5f16";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/df54923e9eb45aca32e3964fdaa0ba10bba2eb5d8256d4f8e3d65a1076a2e020.nar.xz";
    narHash = "sha256:1lgrw01xnxz5byfah3g7jm6613v2kszx0aidp8d3l8v441krjhkx";
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
