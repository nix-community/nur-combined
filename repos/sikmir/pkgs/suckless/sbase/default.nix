{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation {
  pname = "sbase";
  version = "0-unstable-2024-12-09";

  src = fetchgit {
    url = "git://git.suckless.org/sbase";
    rev = "279cec88898c2386430d701847739209fabf6208";
    hash = "sha256-pWR2gN34LkC4i9/AIM6mK0dB3U5XBafmFMm23PGI3Jc=";
  };

  makeFlags = [
    "AR:=$(AR)"
    "CC:=$(CC)"
    "RANLIB:=$(RANLIB)"
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "suckless unix tools";
    homepage = "https://core.suckless.org/sbase/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
