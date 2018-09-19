{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-6fb06a5";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/1ff3e76279e899c635f93b77316087329bf9995a40ee65c22a96e6590f21cf11.nar.xz";
    narHash = "sha256:09ssia1sxnyyk826hb02pl6gknr69ifrjnxi089kyaadk178ffar";
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
