{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation {
  pname = "sbase";
  version = "0-unstable-2024-01-22";

  src = fetchgit {
    url = "git://git.suckless.org/sbase";
    rev = "d335c366f7a2ef74ab8da19b721707110ec821c8";
    hash = "sha256-CkfrtL4yV/HtLnJsMODjArRMzoT4FSgJqDYPHl0MtUU=";
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
