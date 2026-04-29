{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "notifier";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "mohak34";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-qkL+LlmaxBUnPRJH7W7ugcp8J+9YLwkHA42sqFW1hSs=";
  };

  dependencyHash = "sha256-wk4j4raaEgdu2NQtCRRbXOyBDq4ZteRkJwGdgwKZSaI=";

  buildCommand = "bun run build";

  meta = {
    # keep-sorted start
    description = "OpenCode plugin for desktop notifications and sounds on permission, completion, and error events";
    homepage = "https://github.com/mohak34/opencode-notifier";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
