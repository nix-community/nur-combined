{ fetchpatch
, fetchPypi
, lib
, python3Packages
}:
python3Packages.buildPythonPackage rec {
  pname = "ollama";
  version = "0.1.7";
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xHEoaiu+ncmYZCiDHGejpsJ+f7Xj31X0HB4ouNAKgKc=";
  };
  patches = [
    ./loosen-httpx-constraint.patch
  ];

  nativeBuildInputs = [
    python3Packages.poetry-core
  ];
  propagatedBuildInputs = with python3Packages; [
    httpx
    typing-extensions
  ];
  pythonImportsCheck = [ "ollama" ];

  meta = with lib; {
    description = "The official Python client for Ollama";
    homepage = "https://ollama.ai/";
    maintainers = with maintainers; [ javimerino ];
    license = [ licenses.mit ];
  };
}
