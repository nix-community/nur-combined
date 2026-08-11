{ lib
, python3
, fetchPypi
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pysubs2";
  version = "1.6.1";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AmFhHnFzX/d2OXLFGcclk8gGPvy5A5xUr2XzG4HOwRY=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
  ];

  pythonImportsCheck = [ "pysubs2" ];

  meta = with lib; {
    description = "A library for editing subtitle files";
    homepage = "https://pypi.org/project/pysubs2/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
