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
  version = "9.0.4446";

  propagatedBuildInputs = [ archinfo cffi minidump pefile pyelftools pyvex pyxbe sortedcontainers ];

  src = fetchFromGitHub {
    owner = "angr";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-t5xZr60e62M2imRhnsR3mWFF8x06k8gfktg3VvULhbI=";
  };

  binaries = fetchFromGitHub {
    owner = "angr";
    repo = "binaries";
    rev = "9bf9c59002c2fb751ae2357f08fb9f4f8171a4ff";
    sha256 = "sha256-geb78Go9zL3PsfNcPW41WBz3V8Phq9GPOqYlfF1JCDA=";
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
