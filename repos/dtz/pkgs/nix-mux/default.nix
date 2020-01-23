{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-6e9cd30";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/ee4b8fcbed7ef3105cfeeee59cd47af2c1f185772f108f4d6efc815f397144b5.nar.xz";
    narHash = "sha256:19ixfcp3slgnxhjq68j1wrxx5g9qhap62gjkr6zq2l33hlxigsya";
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
