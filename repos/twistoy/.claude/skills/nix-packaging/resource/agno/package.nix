{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  docstring-parser,
  gitpython,
  httpx,
  pydantic-settings,
  pydantic,
  python-dotenv,
  python-multipart,
  pyyaml,
  rich,
  tomli,
  typer,
  typing-extensions,
  # optional
  tantivy,
  pylance,
  lancedb,
  qdrant-client,
  unstructured,
  markdown,
  aiofiles,
}:

buildPythonPackage rec {
  pname = "agno";
  version = "1.7.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "agno-agi";
    repo = "agno";
    rev = "v${version}";
    hash = "sha256-9oO4qyYCgMnC1jtFr39Y76t/5/ybUGIhECP+PLhm92s=";
  };

  sourceRoot = "${src.name}/libs/agno";

  build-system = [ setuptools ];

  dependencies = [
    docstring-parser
    gitpython
    httpx
    pydantic-settings
    pydantic
    python-dotenv
    python-multipart
    pyyaml
    rich
    tomli
    typer
    typing-extensions
  ];

  optional-dependencies = {
    lancedb = [ lancedb tantivy ];
    pylance = [ pylance ];  # Useful for lancedb "hybrid" search
    qdrant = [ qdrant-client ];
    markdown = [ unstructured markdown aiofiles ];
  };

  pythonImportsCheck = [ "agno" ];

  meta = {
    description = "Full-stack framework for building Multi-Agent Systems with memory, knowledge and reasoning";
    homepage = "https://github.com/agno-agi/agno";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "agno";
    platforms = lib.platforms.all;
  };
}
