{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "notifier";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "mohak34";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-c9+RY0D0lyk2pjNZaWxS9KGBtHK7efUKyLcKYBDxBWc=";
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
