{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
}:

buildPythonPackage (finalAttrs: {
  pname = "defusedxml";
  version = "0.7.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-G7MDLbGFkVti18YgnFqHkr5qMqsv7azITgG1LFGqPmk=";
  };

  checkPhase = ''
    ${python.interpreter} tests.py
  '';

  pythonImportsCheck = [ "defusedxml" ];

  meta = with lib; {
    description = "Python module to defuse XML issues";
    homepage = "https://github.com/tiran/defusedxml";
    license = licenses.psfl;
    maintainers = with maintainers; [ fab ];
  };
})
