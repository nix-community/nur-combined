{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "saait";
  version = "0.8";

  src = fetchurl {
    url = "https://codemadness.org/releases/saait/saait-${finalAttrs.version}.tar.gz";
    hash = "sha256-ulYpErfzpSiE0pKyDroEdxmVQT5wFdNFT5Bf88AhBAQ=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "The most boring static page generator";
    homepage = "https://git.codemadness.org/saait/file/README.html";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
