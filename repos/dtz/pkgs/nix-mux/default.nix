{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-e4904bc";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/efeb09c3d17a7ac576e3f1168d6b54c14de0779fb8959b63a8711b6e0cb8ff03.nar.xz";
    narHash = "sha256:07b37y6i00k9dbffinzl3fnih00prniwb3bl3w8hw076k3y59x3q";
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
