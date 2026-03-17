{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "notifier";
  version = "0.1.34";

  src = fetchFromGitHub {
    owner = "mohak34";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-5JPwWq2RDCHN2GRr4kW+eBcTF6HcfIS7okjBlfnq0NQ=";
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
