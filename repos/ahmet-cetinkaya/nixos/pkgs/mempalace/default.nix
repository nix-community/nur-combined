{
  lib,
  buildPythonApplication,
  fetchPypi,
  hatchling,
  chromadb,
  huggingface-hub,
  numpy,
  python-dateutil,
  pyyaml,
  tokenizers,
}: let
  pname = "mempalace";
  version = "3.10.0";
in
  buildPythonApplication {
    inherit pname version;
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-x28a6ugaaLaVJJ+UDmdx8UeuO+c9mbtDrZNTDeEssfQ=";
    };

    propagatedBuildInputs = [
      chromadb
      huggingface-hub
      numpy
      python-dateutil
      pyyaml
      tokenizers
    ];

    nativeBuildInputs = [hatchling];

    # Dev/test extras (pytest, hypothesis, ruff, pre-commit) are intentionally
    # not propagated; onnxruntime extras (coreml/dml) are macOS/Windows-only.
    pythonImportsCheck = ["mempalace"];

    meta = with lib; {
      description = "Give your AI a memory — mine projects and conversations into a searchable palace";
      homepage = "https://github.com/MemPalace/mempalace";
      license = licenses.mit;
      maintainers = ["Ahmet Çetinkaya <contact@ahmetcetinkaya.me>"];
      mainProgram = "mempalace";
    };
  }
