{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-39e27cd";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/2fa972b056644a5512105d19d5fcefda5e4d9f141a510b04f1b94c3a5b24c243.nar.xz";
    narHash = "sha256:0jr57zy849z83ialqm43bad156h9i99r8anxq911dqxv41mk5dzb";
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
