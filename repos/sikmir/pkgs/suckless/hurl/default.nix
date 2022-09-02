{ lib, stdenv, fetchgit, libressl, libbsd }:

stdenv.mkDerivation rec {
  pname = "hurl";
  version = "0.7";

  src = fetchgit {
    url = "git://git.codemadness.org/hurl";
    rev = version;
    hash = "sha256-OXzt5sc1sZesKY1YmeGc3zuo9GxMYfYDvovCSt/kIdE=";
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
}
