{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
  typescript,
}:
mkOpencodePlugin rec {
  pname = "dynamic-context-pruning";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "Opencode-DCP";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-9jShUIMZVBpImOo2vmC+tIvGExOhvpGSYAMJ254qEn0=";
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
