{
  sources,

  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  inherit (sources.serena) pname src;
  version = lib.removePrefix "v" sources.serena.version;
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
}
