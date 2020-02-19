{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-81cbfa2";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/f620f38277e13685fe394e9c7c3087e571a2c88581e24cbfd7b91c97c989dce3.nar.xz";
    narHash = "sha256:0xv36cpk5nz2qrcjycv0j7h1wd63pncaip7bg3n9x6f8459my9g9";
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
