{ archinfo
, cffi
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
, sortedcontainers
}:

buildPythonPackage rec {
  pname = "cle";
  version = "9.0.6588";

  propagatedBuildInputs = [ archinfo cffi minidump pefile pyelftools pyvex pyxbe sortedcontainers ];

  src = fetchFromGitHub {
    owner = "angr";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-oPzCYEPwKaRnSOjbozQnLhaQuAS/JheJYbRSI8rajec=";
  };

  binaries = fetchFromGitHub {
    owner = "angr";
    repo = "binaries";
    rev = "v${version}";
    sha256 = "sha256-MMiQhN7E4rrVUQecA0qK+kdBaZJCmhfHblfNe7BM58Y=";
  };

  checkInputs = [ nose nose2 ];

  checkPhase = ''
    cp -r ${binaries} /build/binaries
    nose2 -s tests/
  '';

  meta = with pkgs.lib; {
    description = "CLE loads binaries and their associated libraries, resolves imports and provides an abstraction of process memory the same way as if it was loader by the OS's loader.";
    homepage = "https://github.com/angr/cle";
    license = licenses.bsd2;
    maintainers = [ maintainers.pamplemousse ];
  };
}
