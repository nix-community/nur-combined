{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
  typescript,
}:
mkOpencodePlugin rec {
  pname = "dynamic-context-pruning";
  version = "2.1.5";

  src = fetchFromGitHub {
    owner = "Opencode-DCP";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-sE7Rwzh1pRzmecPBeq9dcstnuhDBPC0Ts9sX6kzQTyw=";
  };

  dependencyHash = "sha256-j5sb70P0Mn/yV4zqWg8U8VbNacJlZZ0zeXC5nG6+/bk=";

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
