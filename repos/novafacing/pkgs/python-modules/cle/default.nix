{ archinfo
, buildPythonPackage
, fetchFromGitHub
, git
, minidump
, nose
, nose2
, pefile
, pkgs
, pyelftools
, pyvex
, pyxbe
, unicorn
, sortedcontainers
}:

buildPythonPackage rec {
  pname = "cle";
  version = "8.20.7.27";

  propagatedBuildInputs = [ archinfo pkgs.python37Packages.cffi minidump pefile pyelftools pyvex pyxbe sortedcontainers unicorn ];

  src = fetchFromGitHub {
    owner = "angr";
    repo = pname;
    rev = "900818cc32a30801694f33e08ee4ea86288744be";
    sha256 = "0j996x90bjz22zwwqzlwpgbq0fp7kip37pfgm0smq0qkknicypax";
  };

  binaries = fetchFromGitHub {
    owner = "angr";
    repo = "binaries";
    rev = "f517c1ae88f4a9ccf19f5c90ff1519827df0157c";
    sha256 = "0wiwkjbyk28ln0y0xm8dkd654g56508qdjzcm63nfdlrd9bmqzs4";
  };

  checkInputs = [ binaries nose nose2 ];

  checkPhase = ''
    cp -r ${binaries} /build/binaries
    #nose2 -s tests/
  '';

  meta = with pkgs.lib; {
    description = "CLE loads binaries and their associated libraries, resolves imports and provides an abstraction of process memory the same way as if it was loader by the OS's loader.";
    homepage = "https://github.com/angr/cle";
    license = licenses.bsd2;
    maintainers = [ maintainers.pamplemousse ];
  };
}
