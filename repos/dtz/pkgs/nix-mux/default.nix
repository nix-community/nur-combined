{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-df0c837";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/64ebcf2f33662487c1d858f2286bfe1c0aaf3293b73b70120a0a973451f4fa19.nar.xz";
    narHash = "sha256:0hk4khya6afzg9r2dimwzib8ffsx66a6v1qhfjnkyjcjbmn4hqgl";
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
