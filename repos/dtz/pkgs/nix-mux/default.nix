{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-fc48281";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/7aae08c8402f6a595d3baeac41f8d7d11be46658d6308f4733d65470dda574d9.nar.xz";
    narHash = "sha256:185d49lzph34ppfs44n3c7msj01kyp0sm6csxs26l7gsby0p6g5y";
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
