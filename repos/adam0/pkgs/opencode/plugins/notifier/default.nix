{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "notifier";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "mohak34";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-Pji4jbFewkhD88SilwJAWzmkA+z3/u54KXN74aXjtHk=";
  };

  dependencyHash = "sha256-qCsznzTzW30UzTOxj0dU2dpHb8PVxaZldcgRzhlQmbg=";

  buildCommand = "bun run build";

  meta = {
    # keep-sorted start
    description = "OpenCode plugin for desktop notifications and sounds on permission, completion, and error events";
    homepage = "https://github.com/mohak34/opencode-notifier";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
