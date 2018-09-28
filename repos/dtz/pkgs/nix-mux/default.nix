{ stdenv, runCommandNoCC, lib }:

let
  version = "2.2dtz-mux-39e27cd";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/829b946220eaf60dacf00fbce1fb078161a99d7b06c4eecb5e06268c61d12f45.nar.xz";
    narHash = "sha256:1yb046vnh2dykk20pfbq7fid6g386sisdfbba138xn9wxr01zc1h";
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
