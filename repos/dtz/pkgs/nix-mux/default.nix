{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-4446425";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/d8162ab72d9431e4a892940d0e4869496cdf629d1aee5fc062e947e61fc65b76.nar.xz";
    narHash = "sha256:1v054l02b4085m5w5q11b4gv85njlf8piswaw4gvwcxpm3rmd37d";
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
