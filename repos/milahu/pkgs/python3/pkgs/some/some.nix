{ lib
, python3
, fetchPypi
}:

python3.pkgs.buildPythonApplication rec {
  pname = "some";
  version = "2.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-suuzPBmD5dREV6iI6ztHVN+NHpwhQrxa4GRSJiRB8G8=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.setuptools-scm
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [ "some" ];

  meta = with lib; {
    description = "More than less; less than more";
    homepage = "https://pypi.org/project/some/";
    license = licenses.eupl12;
    maintainers = with maintainers; [ ];
  };
}
