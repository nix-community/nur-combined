{ lib, stdenv, fetchgit, libressl, libbsd }:

stdenv.mkDerivation (finalAttrs: {
  pname = "hurl";
  version = "0.8";

  src = fetchgit {
    url = "git://git.codemadness.org/hurl";
    rev = finalAttrs.version;
    hash = "sha256-/aalBz4HbR8GZYt+gI4o1tfN5PfpSLG1gADcbo0Mp94=";
  };

  buildInputs = [ libressl libbsd ];

  NIX_LDFLAGS = "-lbsd";

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Relatively simple HTTP, HTTPS and Gopher client/file grabber";
    homepage = "https://git.codemadness.org/hurl/file/README.html";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
