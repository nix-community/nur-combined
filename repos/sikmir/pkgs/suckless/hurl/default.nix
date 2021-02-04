{ lib, stdenv, fetchgit, libressl, libbsd }:

stdenv.mkDerivation rec {
  pname = "hurl";
  version = "0.4";

  src = fetchgit {
    url = "git://git.codemadness.org/hurl";
    rev = version;
    sha256 = "09a7l9dhygkvyc6v1jw960rmdvgpzp440f6n94jj71jlqi3k43hq";
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
  };
}
