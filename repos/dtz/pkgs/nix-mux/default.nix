{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-6efe01e";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/23996c7ee22c73b94e1162d299b7891726f630ad54f12a392d67187c65bc36c4.nar.xz";
    narHash = "sha256:0jz33xsa61vc0w6bn3685hrc7hx1h5ik4476hpnriadyn13iisjc";
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
