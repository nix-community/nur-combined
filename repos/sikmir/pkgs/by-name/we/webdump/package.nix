{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "webdump";
  version = "0.2";

  src = fetchgit {
    url = "git://git.codemadness.org/webdump";
    tag = finalAttrs.version;
    hash = "sha256-YtgZkAnbQkIr2fhUYpSp/PaduuBFjxIkrkaROxrmT/0=";
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
