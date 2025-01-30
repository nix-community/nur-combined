{ fetchPypi
, lib
, python3Packages
}:
python3Packages.buildPythonPackage rec {
  pname = "llm-ollama";
  version = "0.8.2";
  pyproject = true;
  src = fetchPypi {
    pname = "llm_ollama";
    inherit version;
    hash = "sha256-cvZ6AdzLsMPl6BHsHmYYYc7Ab0N6Ngrvc6frQzBpwHg=";
  };

  nativeBuildInputs = [
    python3Packages.setuptools
  ];
  propagatedBuildInputs = [
    python3Packages.ollama
  ];

  # We can't add llm as a propagatedBuildInput as it creates a
  # circular dependency.
  dontCheckRuntimeDeps = true;

  meta = with lib; {
    description = "LLM plugin providing access to models running on local Ollama server.";
    homepage = "https://github.com/taketwo/llm-ollama";
    maintainers = with maintainers; [ javimerino ];
    license = licenses.mit;
  };
}
