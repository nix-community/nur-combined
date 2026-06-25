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
  version = "3.1.14";

  src = fetchFromGitHub {
    owner = "Opencode-DCP";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-MABdjzmoULt+mYEkH01Lo1FfdZciQ4mlI/CLWS3qTmI=";
  };

  dependencyHash = "sha256-C0Us4cFtLJxnRVA4onVFgoARTjYlFbstjXt5KNqMFEc=";

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
