{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-3f6f9be";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/30a0bdbb2e343a96a2bdfc4d409f213094a095066a8a863517738c6532fa1a5b.nar.xz";
    narHash = "sha256:1rlcyhsqmvj42ch0ap4a25x4m9h5cvcr5c168hi5xay49rc731xs";
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
