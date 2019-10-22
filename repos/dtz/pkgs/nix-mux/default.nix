{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-2a622c0";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/fb552c93554d318353d27dec50ed70c5928353a9dcba16ba3613de1f84e3a449.nar.xz";
    narHash = "sha256:1schbfmljbg0yr2ls9g1f89k280wnlxywmmrjdi7kdckrpambj9p";
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
