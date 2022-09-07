{ lispPackages, fetchgit, openssl, curl, gnupg, xdg-utils, git, ... }:

lispPackages.buildLispPackage {

  baseName = "tinmop";
  version = "unstable-2021-12-14";

  buildSystems = [ ];

  description = "An opinionated TUI client for gemini and pleroma";

  deps = [ ];

  buildInputs = [ openssl curl gnupg xdg-utils git ];

  src = fetchgit {
    url = "https://notabug.org/cage/tinmop";
    rev = "50bf7a87164f16b3c472a7b0e715c01008221412";
    sha256 = "01jjvjr68kmf3jv5yxhp7ag7jn3mqiiy6hyfwb5lg2nq16zx0jqq";
  };
}
