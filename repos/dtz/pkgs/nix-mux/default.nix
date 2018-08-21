{ stdenv, runCommandNoCC, lib }:

let
  version = "2.1dtz-mux-77907fd";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/e868a0a2c161556a6b26512d2ec29fb213119cda1e2223179935fa9798e0a71e.nar.xz";
    narHash = "sha256:03v6jr74n1gshawy136g9nhj3pxivmy17mhdfgvc05s9ckhz7xdv";
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
