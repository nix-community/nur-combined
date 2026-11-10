{
  lib,
  melpaBuild,
  fetchFromGitHub,
  agent-shell,
}:

melpaBuild {
  pname = "agent-shell-links";
  version = "0-unstable-2026-10-30";

  src = fetchFromGitHub {
    owner = "ultronozm";
    repo = "agent-shell-links.el";
    rev = "c7bcc1abb8bf4d79beee064ff2d18c58f5eade2a";
    hash = "sha256-+7jKGQOKJHtfOcYkjOmuB7urWV1YrzL105pLz1iPu5E=";
  };

  packageRequires = [ agent-shell ];

  turnCompilationWarningToError = true;

  meta = {
    homepage = "https://github.com/ultronozm/agent-shell-links.el";
    description = "Bookmarks and Org links for agent-shell sessions";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
