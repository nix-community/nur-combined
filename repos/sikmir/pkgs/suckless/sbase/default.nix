{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sbase";
  version = "2021-09-11";

  src = fetchgit {
    url = "git://git.suckless.org/sbase";
    rev = "371f3cb5ec3b8ef3135b3729326bfd6c7b7cb85c";
    hash = "sha256-0q3v7E82agburNaOKtXqKBHSLQHuq8swLvPdHsTJmIM=";
  };

  makeFlags = [ "AR:=$(AR)" "CC:=$(CC)" "RANLIB:=$(RANLIB)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "suckless unix tools";
    homepage = "https://tools.suckless.org/sbase/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
