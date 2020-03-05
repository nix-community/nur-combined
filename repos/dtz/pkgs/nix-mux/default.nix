{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-e892ccd";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/c71edd4b5c8bcd40faef48cb3a371221ff4dab034985f4b2b4bf2513cdd14cda.nar.xz";
    narHash = "sha256:1xc3rdhnj0lvbpjklr5by3gkylw5qv0r2rx3znym4s006dgj6nj5";
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
