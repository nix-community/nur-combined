{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy27,
  funcsigs,
  six,
  pbr,
  python,
  pytest,
}:

buildPythonPackage (finalAttrs: {
  pname = "mock";
  version = "3.0.5";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-g2V9iUyQ1WgdYhVcgr2pwRh4J1JYgO2o/1307IE0N8M=";
  };

  propagatedBuildInputs = [
    six
    pbr
  ]
  ++ lib.optionals isPy27 [ funcsigs ];

  # On PyPy for Python 2.7 in particular, Mock's tests have a known failure.
  # Mock upstream has a decoration to disable the failing test and make
  # everything pass, but it is not yet released. The commit:
  # https://github.com/testing-cabal/mock/commit/73bfd51b7185#diff-354f30a63fb0907d4ad57269548329e3L12
  #doCheck = !(python.isPyPy && python.isPy27);
  doCheck = false; # Infinite recursion pytest

  checkPhase = ''
    ${python.interpreter} -m unittest discover
  '';

  checkInputs = [
    pytest
  ];

  meta = with lib; {
    description = "Mock objects for Python";
    homepage = "http://python-mock.sourceforge.net/";
    license = licenses.bsd2;
  };

})
