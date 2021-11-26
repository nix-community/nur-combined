{ lib, stdenv, fetchgit }:

stdenv.mkDerivation {
  pname = "saait";
  version = "2020-12-24";

  src = fetchgit {
    url = "git://git.codemadness.org/saait";
    rev = "134ff98c58a8cca78caf918cc6dddc3a24155490";
    sha256 = "sha256-bx21xlIAHlPzkKS3jXqNoTJlL1YV1M7zDKUAEjUF8Sg=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "The most boring static page generator";
    homepage = "https://git.codemadness.org/saait/file/README.html";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
