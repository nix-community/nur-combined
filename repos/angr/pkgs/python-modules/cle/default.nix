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
  version = "9.0.5405";

  propagatedBuildInputs = [ archinfo cffi minidump pefile pyelftools pyvex pyxbe sortedcontainers ];

  src = fetchFromGitHub {
    owner = "angr";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-G6ERkVlQkdHCEurg/pamGg8gXWa+u492snzF3ZURCnQ=";
  };

  binaries = fetchFromGitHub {
    owner = "angr";
    repo = "binaries";
    rev = "v${version}";
    sha256 = "sha256-q5Wi+q8YWhhKws7LagKxZ7a1Cni/qgTzANb6msPzWWg=";
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
