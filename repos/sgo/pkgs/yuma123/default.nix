{ stdenv, fetchurl, lib, libxml2, libssh2, ncurses5, zlib, readline, openssl, autoreconfHook }:


stdenv.mkDerivation rec {
  pname = "yuma123";
  version = "2.11";

  src = fetchurl {
    url    = "mirror://sourceforge/yuma123/yuma123_2.11.tar.gz";
    sha256 = "1x4lxbh0m5mwvj0k46izbbndzw1akljv3rchwl92j1nv1dghwpzd";
  };
  nativeBuildInputs = [ autoreconfHook ];
  doCheck=true;
  buildInputs = [ libxml2 libssh2 openssl ncurses5 zlib readline ];
}
