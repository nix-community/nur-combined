{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sbase";
  version = "2021-06-18";

  src = fetchgit {
    url = "git://git.suckless.org/sbase";
    rev = "3d8481f01dc9f579666a15a5d510358fe50cbecf";
    sha256 = "sha256-GCeU0j/VsqzTwWwDzcbEgEZrllLcCwO8OwekC6fkKEw=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "suckless unix tools";
    homepage = "https://tools.suckless.org/sbase/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
