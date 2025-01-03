{ fetchPypi
, lib
, python3Packages
}:
python3Packages.buildPythonPackage rec {
  pname = "llm-ollama";
  version = "0.8.1";
  pyproject = true;
  src = fetchPypi {
    pname = "llm_ollama";
    inherit version;
    hash = "sha256-eNfzNNWeReN7WuVeY0oWERu2yK8dVRWMGvxdBoelz7c=";
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
