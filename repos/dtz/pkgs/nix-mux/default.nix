{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-89e0eff";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/f183826f6c2a4df52bd29e4df8ca3fc593e55d888c641534383289a77e0b5c5b.nar.xz";
    narHash = "sha256:1dx77xw3ljshhfr8y30c6zxz1fqmymjg17g15pf4kzlfginss2w5";
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
