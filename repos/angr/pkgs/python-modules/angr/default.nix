{ ailment
, archinfo
, buildPythonPackage
, cachetools
, capstone
, cffi
, claripy
, cle
, cooldict
, dpkt
, fetchFromGitHub
, GitPython
, isPy3k
, itanium_demangler
, mulpyplexer
, networkx
, pkgs
, progressbar2
, protobuf
, psutil
, pycparser
, pyvex
, rpyc
, unicorn
, sortedcontainers
}:

buildPythonPackage rec {
  pname = "angr";
  version = "8.19.10.30";
  disabled = !isPy3k;

  propagatedBuildInputs = [
    ailment
    archinfo
    cachetools
    capstone
    cffi
    claripy
    cle
		cooldict
    dpkt
    GitPython
    itanium_demangler
    mulpyplexer
    networkx
    progressbar2
    protobuf
    psutil
    pycparser
    pyvex
    rpyc
    unicorn
    sortedcontainers
  ];

  src = fetchFromGitHub {
    owner = "angr";
    repo = pname;
    rev = "eef5b2f07df74d22b87cf8c7f9f3578c3af918b7";
    sha256 = "002f9m6l0m0ws5f6wzg541v2s798p1l9ba59ir0r02yicmkr96sf";
  };

  setupPyBuildFlags = [
    "--plat-name x86_64-linux"
  ];

  # Many tests are broken.
  doCheck = false;

  # Verify imports still work.
  pythonImportsCheck = [ "angr" ];


  meta = with pkgs.lib; {
    description = "A powerful and user-friendly binary analysis platform";
    homepage = "https://angr.io/";
    license = licenses.bsd2;
    maintainers = [ maintainers.pamplemousse ];
  };
}
