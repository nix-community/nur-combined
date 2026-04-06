{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
  typescript,
}:
mkOpencodePlugin rec {
  pname = "dynamic-context-pruning";
  version = "3.1.9";

  src = fetchFromGitHub {
    owner = "Opencode-DCP";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-a5WrJ6OWgrF/fNmo7Dq6TiyJcsU+utbH5NaCP6wsJFk=";
  };

  dependencyHash = "sha256-+VbW5R9zVDu2QSQud7DJ8sya/pR1aKNayzLZVF9hP9s=";

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
