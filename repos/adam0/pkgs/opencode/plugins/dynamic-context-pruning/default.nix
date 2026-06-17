{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  typescript,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "dynamic-context-pruning";
  version = "3.1.13";

  src = fetchFromGitHub {
    owner = "Opencode-DCP";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-Tr1xeMzPR2GwpZYxxPTOEU9hpQ1SFKfNoGBMMfqYNIE=";
  };

  dependencyHash = "sha256-btB3XLGueHTOgaOe22h0xjylQcGfFqT4JQVTMlxp4jA=";

  nativeBuildInputs = [typescript];

  buildCommand = "tsc -p tsconfig.json";

  meta = {
    # keep-sorted start
    description = "OpenCode plugin for dynamic context pruning and token usage optimization";
    homepage = "https://github.com/Opencode-DCP/opencode-dynamic-context-pruning";
    license = lib.licenses.agpl3Plus;
    # keep-sorted end
  };
}
