{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
  typescript,
}:
mkOpencodePlugin rec {
  pname = "dynamic-context-pruning";
  version = "3.1.3";

  src = fetchFromGitHub {
    owner = "Opencode-DCP";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-N+X4UFo44en+p1+bYzu+WcAUjvTnyxEmLnBP6HPKZts=";
  };

  dependencyHash = "sha256-0kGXgBOC/7qXV8sDiTLe0H3RO/KlwbZTIudMxT5zbMI=";

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
