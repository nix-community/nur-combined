{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdhcp";
  version = "0.1-unstable-2018-11-22";

  src = fetchgit {
    url = "git://git.2f30.org/sdhcp";
    rev = "8455fd2d090bd9b227340c30c92c6aa13302c91a";
    hash = "sha256-bN2jFO+cp1Vck0RvB8q2qwMYpUARH2mjZuWs3FkhxR0=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace-fail "ranlib" "\$(RANLIB)"
  '';

  makeFlags = [
    "AR:=$(AR)"
    "CC:=$(CC)"
    "PREFIX=$(out)"
    "RANLIB:=$(RANLIB)"
  ];

  meta = {
    description = "Simple dhcp client";
    homepage = "http://git.2f30.org/sdhcp/";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
