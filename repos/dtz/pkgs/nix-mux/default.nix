{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-9ed40da";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/b7b12c37d3fd397a171e3cece2b20dee9e2828009f367e4622d7cf7cf7a4cffc.nar.xz";
    narHash = "sha256:00fbnlc52j321x6za7hx6sl6skzkw56wrxl5y6h4rg54r87i9g9q";
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
