{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "liblzf";
  version = "3.6";

  src = fetchurl {
    url = "http://dist.schmorp.de/liblzf/liblzf-${finalAttrs.version}.tar.gz";
    hash = "sha256-nF3gH3ucyuQMP2GdJqer7JmGwGw20mDBec7dBLiftGo=";
  };

  meta = {
    description = "LibLZF - a free, fast, easy to embed compression library.";
    homepage = "http://software.schmorp.de/pkg/liblzf";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.nim65s ];
  };
})
