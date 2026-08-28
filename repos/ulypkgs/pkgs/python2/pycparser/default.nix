{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycparser";
  version = "2.21";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-5kT97BL3hy+GxY/3kNpFYhixD4Y5cCSVFtYKXqyncgY=";
  };

  checkPhase = ''
    ${python.interpreter} -m unittest discover -s tests
  '';

  meta = with lib; {
    description = "C parser in Python";
    homepage = "https://github.com/eliben/pycparser";
    license = licenses.bsd3;
    maintainers = with maintainers; [ domenkozar ];
  };
})
