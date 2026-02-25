{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
  typescript,
}:
mkOpencodePlugin rec {
  pname = "dynamic-context-pruning";
  version = "2.1.8";

  src = fetchFromGitHub {
    owner = "Opencode-DCP";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-6kh2fh2ZkRuJS+8STpfEGpJS5yAtITx8sfLLWsH8mbM=";
  };

  dependencyHash = "sha256-NTGo30IouPx94hwJiw+/MHChakq1+BkQs6BNLrO9tIE=";

  nativeBuildInputs = [typescript];

  postInstall = ''
    cd "$out"

    bun scripts/generate-prompts.ts
    tsc -p tsconfig.json
  '';

  meta = {
    description = "OpenCode plugin for dynamic context pruning and token usage optimization";
    homepage = "https://github.com/Opencode-DCP/opencode-dynamic-context-pruning";
    license = lib.licenses.agpl3Plus;
  };
}
