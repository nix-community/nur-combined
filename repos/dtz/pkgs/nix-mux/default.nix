{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-f35a773";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/fbdb47d1faaf70293efe5b229956413064286fdc68ebe803e7393ce867f10580.nar.xz";
    narHash = "sha256:09nm4gq57m77rd7c2ja3rkf3wrxsg0rn4zfdg08bdx76j1cdw4vr";
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
