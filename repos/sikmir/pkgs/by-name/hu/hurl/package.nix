{
  lib,
  stdenv,
  fetchurl,
  libressl,
  libbsd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hurl";
  version = "0.8";

  src = fetchurl {
    url = "https://codemadness.org/releases/hurl/hurl-${finalAttrs.version}.tar.gz";
    hash = "sha256-APrPH2qlB6+FRPUK1nItHxNySzVT26Ku0auGxNdrQsE=";
  };

  buildInputs = [
    libressl
    libbsd
  ];

  env.NIX_LDFLAGS = "-lbsd";

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Relatively simple HTTP, HTTPS and Gopher client/file grabber";
    homepage = "https://git.codemadness.org/hurl/file/README.html";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
