{ stdenv, runCommandNoCC, lib }:

let
  version = "2.1dtz-mux-fb3cf22";
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/45e362ae522e41d9e0d185de591ef56305b4ac4890ff02bd13d3e8b61d48c151.nar.xz";
    narHash = "sha256:0314995h1vvgg3izh4zddf72blz748qks7iqwhx0hbsz3fgy4mqx";
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
