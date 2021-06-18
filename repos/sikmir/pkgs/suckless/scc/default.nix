{ lib, stdenv, fetchgit }:

stdenv.mkDerivation {
  pname = "scc";
  version = "2021-05-30";

  src = fetchgit {
    url = "git://git.simple-cc.org/scc";
    rev = "cbd81e63f9c872b7817b137e4b66ee4801a18467";
    sha256 = "sha256-VdRZ7VR8Uzl3DYMCDlxzbFW3R9dGmYfWue7uSi58ug0=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  #doCheck = true;
  checkTarget = "tests";

  meta = with lib; {
    description = "Simple c99 compiler";
    homepage = "https://www.simple-cc.org/";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
