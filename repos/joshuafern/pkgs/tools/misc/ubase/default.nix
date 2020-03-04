{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "ubase";
  version = "unstable-2019-03-12";

  src = fetchgit {
    url = "git://git.suckless.org/${pname}";
    rev = "3c88778c6c85d97fb63c41c05304519e0484b07c";
    sha256 = "0j38k85kngdnnqj00y3gfdcid3yivpwv4f2hz5fnwpswpcqqxq71";
  };

  postPatch = ''
    sed -i -e '1i#include <sys/sysmacros.h>' \
      mknod.c mountpoint.c stat.c libutil/tty.c
  '';

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "suckless linux base utils";
    license = licenses.mit;
    #maintainers = with maintainers; [ dtzWill ];
  };
}
