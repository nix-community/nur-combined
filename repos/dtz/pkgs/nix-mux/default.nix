{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-baabdff";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/e03a9fb106b6d2745a788312f16e63ae8b8bd1a2e4ed584b65d089e0990a68d6.nar.xz";
    narHash = "sha256:05mgvfswlfdqwmcpd1sldvfs16rjnalg1b5i6r8kqzx7098l2d41";
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
