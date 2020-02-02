{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-c6d8475";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/408ce7d0a38bff96f4fe237fa8b64633ffa075486c5b9f9a6a13080753810725.nar.xz";
    narHash = "sha256:085nh28cns8kh7f26hj9bldr55fn6vs8zh3svsj9bzxdx2lgibs9";
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
