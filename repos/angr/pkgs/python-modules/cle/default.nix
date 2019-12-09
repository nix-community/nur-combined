{ archinfo
, cffi
, buildPythonPackage
, fetchFromGitHub
, git
, nose
, pefile
, pkgs
, pyelftools
, pyvex
, sortedcontainers
}:

buildPythonPackage rec {
  pname = "cle";
  version = "8.19.10.30";

  propagatedBuildInputs = [ archinfo cffi pefile pyelftools pyvex sortedcontainers ];

  src = fetchFromGitHub {
    owner = "angr";
    repo = pname;
    rev = "fceb6b1a9591cdda8fdd4f018d6a498c9fca2268";
    sha256 = "1zs94ridvvxkwvmrhwhqfmkvm005b8fhhavqhmv7dh0znbg42j9f";
  };

  binaries = fetchFromGitHub {
    owner = "angr";
    repo = "binaries";
    rev = "556b7a100e9ba386bb1c0a8fbfba72e9893f33bd";
    sha256 = "00ag6wc2dv3n0qwjkmpl6nf9vcbfih4jgh2bnfar325yw258zgg2";
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
