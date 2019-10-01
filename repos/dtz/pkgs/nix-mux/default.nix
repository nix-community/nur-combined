{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-d54b453";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/ee290930232f22ca703b812dbddb3aca9d75a24bc7bd9fa93824f7c65eed38b9.nar.xz";
    narHash = "sha256:03avgd722jzmykjzqaywb67gzvzvl9nkii1n78g5i9wv2hg6h237";
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
