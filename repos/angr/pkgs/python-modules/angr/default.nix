{ ailment
, archinfo
, buildPythonPackage
, cachetools
, capstone
, cffi
, claripy
, cle
, cppheaderparser
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
  version = "9.0.6588";
  disabled = !isPy3k;

  propagatedBuildInputs = [
    ailment
    archinfo
    cachetools
    capstone
    cffi
    claripy
    cle
    cppheaderparser
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
    rev = "v${version}";
    sha256 = "sha256-0Z9i1Glu00NPlN3kJ0HEnp9kUwywV4SXFjGKjUJwBVg=";
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
