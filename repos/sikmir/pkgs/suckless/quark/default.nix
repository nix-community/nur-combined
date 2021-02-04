{ lib, stdenv, fetchgit }:

stdenv.mkDerivation {
  pname = "quark";
  version = "2021-01-24";

  src = fetchgit {
    url = "git://git.suckless.org/quark";
    rev = "87ae2e9212c5cc7309eefa2a3f49a758862db6c7";
    sha256 = "08gwb9rmj0d6z5p15vk5r7jv0wm80143mkzkq3cmmpd96mm689yw";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Extremely small and simple HTTP GET/HEAD-only web server for static content";
    homepage = "http://tools.suckless.org/quark";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
  };
}
