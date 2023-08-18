{ lib
, buildPythonPackage
, fetchPypi
, poetry-core
, pylint
, tomli
}:

buildPythonPackage rec {
  pname = "pylint-per-file-ignores";
  version = "1.2.1";
  format = "pyproject";
  
  src = fetchPypi {
    pname = "pylint_per_file_ignores";
    inherit version;
    sha256 = "sha256-wodbmCw+3ONjc3Lv3EiJhnlmxRUxNie+oyuFWLh2tNo=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    pylint
    tomli
  ];

  pythonImportsCheck = [ "pylint_per_file_ignores" ];

  meta = with lib; {
    homepage = "https://github.com/christopherpickering/pylint-per-file-ignores";
    description = "This pylint plugin will enable per-file-ignores in your project!";
    license = licenses.mit;
    maintainers = with maintainers; [ graham33 ];
  };
}
