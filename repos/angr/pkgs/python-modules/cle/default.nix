{ archinfo
, cffi
, buildPythonPackage
, fetchFromGitHub
, git
, minidump
, nose
, pefile
, pkgs
, pyelftools
, pyvex
, sortedcontainers
}:

buildPythonPackage rec {
  pname = "cle";
  version = "8.20.1.7";

  propagatedBuildInputs = [ archinfo cffi minidump pefile pyelftools pyvex sortedcontainers ];

  src = fetchFromGitHub {
    owner = "angr";
    repo = pname;
    rev = "18f073190e37310737ee2d79ba52f72a481b4a9f";
    sha256 = "0yn108y7iy392cj50nwzl9qqs9pn2bda75firagjgd9fnndqr560";
  };

  binaries = fetchFromGitHub {
    owner = "angr";
    repo = "binaries";
    rev = "0a0cd2e6a2aadd1af7be137c5719650d52d5fa28";
    sha256 = "1iz294sjvam9kfl5jvcdyrf6fi7y57vfzjkyi316qm0hixcf4xwb";
  };

  checkInputs = [ binaries nose ];

  checkPhase = ''
    cp -r ${binaries} /build/binaries
    nosetests tests/
  '';

  # Verify import still works.
  pythonImportsCheck = [ "cle" ];


  meta = with pkgs.lib; {
    description = "CLE loads binaries and their associated libraries, resolves imports and provides an abstraction of process memory the same way as if it was loader by the OS's loader.";
    homepage = "https://github.com/angr/cle";
    license = licenses.bsd2;
    maintainers = [ maintainers.pamplemousse ];
  };
}
