{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-0e4f4b6";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/ddd94a6a6dc32e3fbce8070992866e737e7812cc4486ff5a9312b40e5158e411.nar.xz";
    narHash = "sha256:054wc8h27byhg11ix4bpsp4anxhxa6icchb6kgkg305z9i1zaa08";
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
