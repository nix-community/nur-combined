{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-0747e31";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/5e290cf40b75e5123eea4325cfc9876449cd1b04170ac684b7506d9e1b4a3fe7.nar.xz";
    narHash = "sha256:1dzl9q9x633ww5c5xyb64xqmd3g91hhdgq9rgwpcvgasd4w8yyvh";
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
