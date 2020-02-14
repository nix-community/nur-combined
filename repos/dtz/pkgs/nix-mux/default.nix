{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-c6d8475";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/0fbfb03662e7a9dff921e691ccfa50e3f5ca6f3108abc7a7321d683113556cd0.nar.xz";
    narHash = "sha256:1z3lpsx2x4iv5alcwy4k79bv1nhkig1g43d4wrdffngbh56wxy5n";
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
