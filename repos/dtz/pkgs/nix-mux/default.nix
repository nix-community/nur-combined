{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-1763993";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/17672f6c4c56db4e65bfb2932edb453e6fbbd4eeca0bd72eddf12149a1e78048.nar.xz";
    narHash = "sha256:08imxs9inrnp4xbilss410ini5l816vs1abv3frgaq5hw8shnnvi";
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
