{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation {
  pname = "sbase";
  version = "0-unstable-2025-09-19";

  src = fetchgit {
    url = "git://git.suckless.org/sbase";
    rev = "055cc1ae1b3a13c3d8f25af0a4a3316590efcd48";
    hash = "sha256-brL6NL3xv0ZrAO9hWJRr1wQy6//UzwoF0Hxreqzar50=";
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
