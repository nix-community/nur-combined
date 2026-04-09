{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "lazy-mcp";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "orionpax1997";
    repo = "opencode-${pname}";
    rev = "d0ea57186d07f945269fd06b0bd4b281c0c88d79";
    hash = "sha256-O2kk30Nx6jeHO7xesOs/5bCd/izK/rjE1gkutd6Is1M=";
  };

  dependencyHash = "sha256-+HAmAO4dJREPtY7I3g7mNu9ehAsWsTa+OWGb8qiN+KE=";

  buildCommand = "bun build src/index.ts --outfile dist/index.js --target node --format esm";

  meta = {
    description = "OpenCode plugin for skill-embedded MCP support with lazy loading";
    homepage = "https://github.com/orionpax1997/opencode-lazy-mcp";
    license = lib.licenses.mit;
  };
}
