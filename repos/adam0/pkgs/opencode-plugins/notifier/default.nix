{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "notifier";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "mohak34";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-2qwRnZC6wksYfOKzVS+FLwiGaXKJtURkw6QkBfY3tZQ=";
  };

  dependencyHash = "sha256-qCsznzTzW30UzTOxj0dU2dpHb8PVxaZldcgRzhlQmbg=";

  postInstall = ''
    cd "$out"
    bun run build
  '';

  meta = {
    description = "OpenCode plugin for system notifications and sounds";
    homepage = "https://github.com/mohak34/opencode-notifier";
    license = lib.licenses.mit;
  };
}
