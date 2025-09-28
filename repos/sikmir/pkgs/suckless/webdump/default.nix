{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "webdump";
  version = "0-unstable-2025-09-21";

  src = fetchgit {
    url = "git://git.codemadness.org/webdump";
    rev = "31fac2476f06b72f3d8bc7ac654cfde4e8452525";
    hash = "sha256-RsYPcKSjunI2UIKN5rrG/w+cLuSRnNN20AEWk7hZBY0=";
  };

  makeFlags = [ "RANLIB:=$(RANLIB)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "HTML to plain-text converter for webpages";
    homepage = "https://git.codemadness.org/webdump/file/README.html";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
