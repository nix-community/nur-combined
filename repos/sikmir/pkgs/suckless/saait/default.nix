{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "saait";
  version = "0.8";

  src = fetchgit {
    url = "git://git.codemadness.org/saait";
    rev = version;
    hash = "sha256-W86JAYUsyvOWt/YTqXfqMA/CwQq7uVIV1F6+AeRB/8s=";
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
