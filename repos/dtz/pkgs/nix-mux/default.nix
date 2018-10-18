{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-df0c837";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/8cb4c20efe27907fda5437ef19ed529faf59519b3757ef38ba809747801e85b8.nar.xz";
    narHash = "sha256:1kmmx8s31aw1rhdn2dr5gp31vnlwm80fzaacd77nphzv8gyizifb";
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
