{ lispPackages, fetchgit, openssl, curl, gnupg, xdg-utils, git, gettext, ncurses, sqlite }:

lispPackages.buildLispPackage {

  baseName = "tinmop";
  version = "unstable-2022-10-01";

  buildSystems = [ ];

  description = "Opinionated TUI client for gemini and pleroma";

  deps = [ ];

  buildInputs = [ openssl curl gnupg xdg-utils git gettext ncurses sqlite ];

  src = fetchgit {
    url = "https://notabug.org/cage/tinmop";
    rev = "1d718771f0ccfc621b5f791d55d78c2b677055fe";
    sha256 = "047qdj4was6ql6p7d6q7194dq1fclf93msspk5jmwfczgkf3v1cw";
  };
}
