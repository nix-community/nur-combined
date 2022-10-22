{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "libgrapheme";
  version = "2.0.1";

  src = fetchgit {
    url = "git://git.suckless.org/libgrapheme";
    rev = "30766915c37d88fc423a4d750227a769e7a307ae";
    hash = "sha256-cBpXRce4494ZVPRFjUQa5UJ6wvEfik2eUzv2bdEbz5E=";
  };

  makeFlags = [ "AR:=$(AR)" "CC:=$(CC)" "RANLIB:=$(RANLIB)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Unicode string library";
    homepage = "https://libs.suckless.org/libgrapheme/";
    license = licenses.isc;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
