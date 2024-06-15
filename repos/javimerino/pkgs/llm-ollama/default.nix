{ fetchPypi
, lib
, python3Packages
}:
python3Packages.buildPythonApplication rec {
  pname = "llm-ollama";
  version = "0.4.2";
  pyproject = true;
  src = fetchPypi {
    pname = "llm_ollama";
    inherit version;
    hash = "sha256-7mZeXer+Csl/seu6PbDjHk9H+kbs5WMpc47HQT/2Rtc=";
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
    broken = versionOlder lib.version "24.05"; # llm-ollama depends on python3Packages.ollama, which was not in 23.11
    description = "LLM plugin providing access to models running on local Ollama server.";
    homepage = "https://github.com/taketwo/llm-ollama";
    maintainers = with maintainers; [ javimerino ];
    license = licenses.mit;
  };
}
