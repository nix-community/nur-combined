{ fetchpatch
, fetchPypi
, lib
, python3Packages
}:
python3Packages.buildPythonPackage rec {
  pname = "ollama";
  version = "0.1.6";
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Zjb/da5UrAdlItzcQGeLFBIIMl0cxdhXhVWfGXsRB94=";
  };
  patches = [
    ./bump-httpx-to-0.26.0.patch
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
    platforms = platforms.all;
  };
}
