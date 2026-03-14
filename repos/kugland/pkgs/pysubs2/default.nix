{ lib
, python3Packages
,
}:
python3Packages.buildPythonPackage rec {
  pname = "pysubs2";
  version = "1.6.1";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-AmFhHnFzX/d2OXLFGcclk8gGPvy5A5xUr2XzG4HOwRY=";
  };
  pyproject = true;
  build-system = with python3Packages; [ setuptools ];
  buildInputs = with python3Packages; [ setuptools ];
  meta = with lib; {
    description = "A Python library for editing subtitle files";
    homepage = "https://github.com/tkarabela/pysubs2";
    license = licenses.mit;
    maintainers = with maintainers; [ kugland ];
  };
}
