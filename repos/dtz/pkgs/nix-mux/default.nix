{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-3e2e6f5";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/f0e05fee842c4e4e401396b8f9c0ee2c246ca40d9390c2bfe2d887ab37286fa2.nar.xz";
    narHash = "sha256:0rmxaq8lwxx1n79w1rqk9xbpkqfpq3ss08rg1iff70s9lbbfg7s1";
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
