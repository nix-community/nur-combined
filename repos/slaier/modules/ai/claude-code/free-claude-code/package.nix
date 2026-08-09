{
  lib,
  python314,
  fetchFromGitHub,
  claude-code,
  writeShellScript,
  curl,
  gnused,
  gnugrep,
  nix-update,
}:
let
  python = python314;
in
python.pkgs.buildPythonPackage {
  pname = "free-claude-code";
  # Upstream publishes no git tags and keeps the version in pyproject.toml,
  # so the version cannot be bumped from tags. `nix-update free-claude-code
  # --flake -u` runs the passthru.updateScript below, which bumps `rev`/`hash`
  # to the latest commit on the default branch and then rewrites `version` to
  # the real version read from that commit's pyproject.toml.
  version = "4.17.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Alishahryar1";
    repo = "free-claude-code";
    rev = "554c7d978779d8cf83ec5428c39b3e05f2c3be3b";
    hash = "sha256-StR2egXQGHlm3WuJlzJAeYpC+Bl6wzW4kX9Gw6Lm6OE=";
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
    aiohttp
    google-auth
    requests
  ];

  pythonRelaxDeps = [
    "aiohttp"
    "discord-py"
    "fastapi"
    "google-auth"
    "markdown-it-py"
    "openai"
    "pydantic"
    "pydantic-settings"
    "python-telegram-bot"
    "requests"
    "tiktoken"
    "uvicorn"
  ];

  doCheck = false;

  passthru.updateScript = writeShellScript "update-free-claude-code" ''
    set -euo pipefail

    pkgfile="modules/ai/claude-code/free-claude-code/package.nix"

    current_rev=$(${lib.getExe gnugrep} -oP 'rev = "\K[0-9a-f]{40}' "$pkgfile")
    # Buffer the full response first: grepping a curl pipe with -m/head closes
    # the pipe early and makes curl die with "23 Failure writing output".
    latest_rev=$(
      ${lib.getExe curl} -fsSL "https://api.github.com/repos/Alishahryar1/free-claude-code/commits/HEAD" \
      | ${lib.getExe gnugrep} -oP '"sha": "\K[0-9a-f]{40}'
    )
    latest_rev=''${latest_rev%%$'\n'*}

    if [ "$current_rev" = "$latest_rev" ]; then
      echo "free-claude-code: already at latest commit $current_rev"
      exit 0
    fi

    echo "free-claude-code: $current_rev -> $latest_rev"
    ${lib.getExe nix-update} free-claude-code --flake --version=branch

    # nix-update --version=branch rewrote `version` to 0-unstable-<date>;
    # restore the real version from the freshly pinned commit's pyproject.toml.
    real_version=$(
      ${lib.getExe curl} -fsSL "https://raw.githubusercontent.com/Alishahryar1/free-claude-code/$latest_rev/pyproject.toml" \
      | ${lib.getExe gnugrep} -oP '^version\s*=\s*"\K[^"]+'
    )
    real_version=''${real_version%%$'\n'*}
    if [ -n "$real_version" ]; then
      ${lib.getExe gnused} -i "s/^\(  version = \"\)[^\"]*\";/\1$real_version\";/" "$pkgfile"
      echo "free-claude-code: version -> $real_version"
    fi
  '';

  meta = {
    description = "Route Claude Code Anthropic API traffic to any LLM provider";
    homepage = "https://github.com/Alishahryar1/free-claude-code";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "fcc-server";
  };
}
