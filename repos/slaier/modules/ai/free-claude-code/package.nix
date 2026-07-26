{
  lib,
  python314,
  fetchFromGitHub,
  claude-code,
}:
let
  python = python314;
in
python.pkgs.buildPythonPackage {
  pname = "free-claude-code";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Alishahryar1";
    repo = "free-claude-code";
    rev = "6bee3104fe5f632cab6c0c7419101fcfa3b42cce";
    hash = "sha256-bI/Is5v31ZFN95x3ZKmV9i6NxYhZ5GNjUzeebR4ScIA=";
  };

  build-system = [ python.pkgs.hatchling ];

  dependencies = with python.pkgs; [
    claude-code
    fastapi
    uvicorn
    httpx
    markdown-it-py
    pydantic
    python-dotenv
    tiktoken
    python-telegram-bot
    discordpy
    pydantic-settings
    openai
    loguru
    jsonschema
  ];

  pythonRelaxDeps = [
    "discord-py"
    "fastapi"
    "markdown-it-py"
    "openai"
    "pydantic"
    "pydantic-settings"
    "tiktoken"
    "uvicorn"
  ];

  doCheck = false;

  meta = {
    description = "Route Claude Code Anthropic API traffic to any LLM provider";
    homepage = "https://github.com/Alishahryar1/free-claude-code";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "fcc-server";
  };
}
