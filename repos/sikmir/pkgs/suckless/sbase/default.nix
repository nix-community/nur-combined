{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation {
  pname = "sbase";
  version = "0-unstable-2024-03-22";

  src = fetchgit {
    url = "git://git.suckless.org/sbase";
    rev = "b30fb56804bfed69b45ef0e944d2e029e4d26258";
    hash = "sha256-X/uqcw0fMDt8AhhFra07eM70hk8Us7/SA5IbocQHZ5k=";
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
