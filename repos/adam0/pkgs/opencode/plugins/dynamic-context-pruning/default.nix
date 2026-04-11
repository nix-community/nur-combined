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
  version = "3.1.9";

  src = fetchFromGitHub {
    owner = "Opencode-DCP";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-a5WrJ6OWgrF/fNmo7Dq6TiyJcsU+utbH5NaCP6wsJFk=";
  };

  dependencyHash = "sha256-+VbW5R9zVDu2QSQud7DJ8sya/pR1aKNayzLZVF9hP9s=";

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
