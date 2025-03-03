{ fetchPypi
, lib
, llm
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

  build-system = [
    python3Packages.setuptools
  ];
  dependencies = with python3Packages; [
    ollama
    pydantic
  ];

  # We can't add llm to dependencies as it creates a circular
  # dependency.
  nativeCheckInputs = [ llm ];

  meta = with lib; {
    description = "LLM plugin providing access to models running on local Ollama server.";
    homepage = "https://github.com/taketwo/llm-ollama";
    changelog = "https://github.com/pycontribs/jira/releases/tag/${version}";
    maintainers = with maintainers; [ javimerino ];
    license = licenses.mit;
  };
}
