{ lib, stdenv, fetchgit }:

stdenv.mkDerivation {
  pname = "saait";
  version = "2022-03-19";

  src = fetchgit {
    url = "git://git.codemadness.org/saait";
    rev = "55da975904aa48d6514cc29b406ec1ea7c1c3719";
    hash = "sha256-o4XFN9Z8hfj4L+R4puKklMIxSy9CjDG5ICsO5SImyPM=";
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
