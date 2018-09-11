{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-6fb06a5";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/70314d820158620b784614172b0a00f497cb30129e48ba1fd5452fadd974fe7d.nar.xz";
    narHash = "sha256:1nvd3z5ppp4f4dpyc6biacjrmk1lidpcz80rrx2m96zl225mvy0m";
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
