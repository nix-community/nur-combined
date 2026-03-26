{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
  typescript,
}:
mkOpencodePlugin rec {
  pname = "dynamic-context-pruning";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "Opencode-DCP";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-h8P0QSvmk1KklnX+a1/AvbpSJyLLWPrQ6cmj4vFKpas=";
  };

  dependencyHash = "sha256-4+MtTe4CD2D873hPPPHxAALkH7MsHak5DHnDaUqI8DU=";

  nativeBuildInputs = [typescript];

  postInstall = ''
    cd "$out"

    tsc -p tsconfig.json
  '';

  meta = {
    description = "OpenCode plugin for dynamic context pruning and token usage optimization";
    homepage = "https://github.com/Opencode-DCP/opencode-dynamic-context-pruning";
    license = lib.licenses.agpl3Plus;
  };
}
