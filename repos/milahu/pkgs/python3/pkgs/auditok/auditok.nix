{ lib
, python3
, fetchPypi
, setuptools
}:

python3.pkgs.buildPythonApplication rec {
  pname = "auditok";
  version = "0.2.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-RsUS4oey4T30gZd0FmrzKyNtdUr75rDchygbIz5a5og=";
  };

  buildInputs = [
    setuptools
  ];

  pythonImportsCheck = [ "auditok" ];

  meta = with lib; {
    description = "A module for Audio/Acoustic Activity Detection";
    homepage = "https://pypi.org/project/auditok/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
