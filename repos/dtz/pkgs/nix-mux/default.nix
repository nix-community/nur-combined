{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-89e0eff";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/070ee0099ebb069736e79c3af33a711f53fde677c644c009086cff2920f27f58.nar.xz";
    narHash = "sha256:1kd25zha27kinig6rr2jpcpchgfd7j730fsrxa74j54xfszpv8jc";
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
