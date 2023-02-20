{ lib
, buildPythonPackage
, fetchPypi
, pylint
, tomli
}:

buildPythonPackage rec {
  pname = "pylint-per-file-ignores";
  version = "1.2.0";
  
  src = fetchPypi {
    pname = "pylint_per_file_ignores";
    inherit version;
    sha256 = "sha256-Zl4p3QIGG73XDO1yc6aXGID+l6OiwVYVrSsx5WdVmzw=";
  };

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
