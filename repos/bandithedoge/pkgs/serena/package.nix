{
  fetchFromGitHub,
  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "serena";
  version = "1.7.0";
  src = fetchFromGitHub {
    owner = "oraios";
    repo = "serena";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IrsD4pnu/47M/O9b8H9c7K8WENGv3FihlqzCB6szBXg=";
  };

  pyproject = true;

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    anthropic
    beautifulsoup4
    cryptography
    docstring-parser
    python-dotenv
    filelock
    flask
    jinja2
    joblib
    lsprotocol
    mcp
    overrides
    pathspec
    psutil
    pydantic
    pygls
    pystray
    python-dotenv
    python-multipart
    pywebview
    pyyaml
    regex
    requests
    ruamel-yaml
    sensai-utils
    starlette
    tiktoken
    tqdm
    types-pyyaml
    urllib3
    werkzeug
  ];

  dontCheckRuntimeDeps = true;

  meta = {
    description = "Powerful MCP toolkit for coding, providing semantic retrieval and editing capabilities - the IDE for your agent";
    homepage = "https://oraios.github.io/serena";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "serena";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
