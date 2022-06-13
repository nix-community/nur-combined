{ lib, stdenv, fetchgit, qbe }:

stdenv.mkDerivation {
  pname = "scc";
  version = "2022-06-06";

  src = fetchgit {
    url = "git://git.simple-cc.org/scc";
    rev = "5c0bbb5ff6603cf20c4e3f4ec16dd7b60799cb85";
    sha256 = "sha256-I/WtGWsYP1Xt0/Sqdx+qBXBY5a8C/IDv+zBnNldBBfg=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace src/cmd/Makefile \
      --replace "git submodule" "#git submodule"
  '';

  #buildInputs = [ qbe ];

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
