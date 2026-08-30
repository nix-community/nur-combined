{
  lib,
  melpaBuild,
  fetchFromGitHub,
  agent-shell,
}:

melpaBuild {
  pname = "agent-shell-links";
  version = "0-unstable-2026-07-08";

  src = fetchFromGitHub {
    owner = "ultronozm";
    repo = "agent-shell-links.el";
    rev = "acf70666c81b465a67580fc38d225169d959bef9";
    hash = "sha256-l0k7m9AJarHRZJ3taM2wwrlQfrsaSuzBCSqjLiTzCUA=";
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
