{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-d54b453";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/7d4ac0c755fed0679f1ca33a818ed98596b3dd102056471688e7086397cbb9a0.nar.xz";
    narHash = "sha256:0vlp8bfxnbbw6r65grd3wgk6521756z8yv6qr0i7v1fhfl9f544l";
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
