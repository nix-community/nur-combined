{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "webdump";
  version = "0.2";

  src = fetchurl {
    url = "https://codemadness.org/releases/webdump/webdump-${finalAttrs.version}.tar.gz";
    hash = "sha256-rsYj92QujrRxHfdsJbP4S41/hO8iUXj+LGmvDzdfvbQ=";
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
