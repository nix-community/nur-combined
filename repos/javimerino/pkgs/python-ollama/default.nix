{ fetchpatch
, fetchPypi
, lib
, python3Packages
}:
python3Packages.buildPythonPackage rec {
  pname = "ollama";
  version = "0.1.9";
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-9kSEsoDbD6A/uJlYDYo6ha83h/0qhbZ2abdD4xOz+vE=";
  };

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
