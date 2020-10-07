{ stdenv, fetchgit, pkgconfig, autoconf, autoconf-archive, automake, libmtp, fuse }:
with stdenv.lib;
let
  pname = "simple-mtpfs";
  version = "0.4.0";
in
  stdenv.mkDerivation {
    inherit pname version;

    nativeBuildInputs = [
      autoconf
      autoconf-archive
      automake
      pkgconfig
    ];

    buildInputs = [
      libmtp
      fuse
    ];


    src = fetchgit {
      url = "https://github.com/phatina/simple-mtpfs";
      rev = "v${version}";
      sha256 = "00nj2c1hf37d9r0rdbc77k3q62iw4hyfvlifxx5b5q0sikda42mw";
    };

    buildPhase = ''
      ./autogen.sh
      mkdir build
      ./configure
      make
    '';

    installPhase = ''
      make install prefix=$out
    '';

    meta = {
      homepage =  "https://github.com/phatina/simple-mtpfs";
      description = "Simple MTP fuse filesystem driver.";
    };
  }
