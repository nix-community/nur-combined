{ buildNpmPackage
, fetchFromGitHub
, lib
}:

let
  inherit (lib) licenses;
in
buildNpmPackage {
  pname = "mark-applier";
  version = "0.5.0";
  meta = {
    description = "Generate a barebones GitHub-readme-themed website from markdown";
    homepage = "https://github.com/suchipi/mark-applier";
    license = licenses.mit;
  };

  src = fetchFromGitHub {
    owner = "suchipi";
    repo = "mark-applier";
    rev = "9ac362292ce6b789573011c0bd39e6c19b591480"; # No version tags
    hash = "sha256-xuI11k+lEXCkEbPXUjAetBHwCYY/UovI3xB4bHvxGBk=";
  };

  npmDepsHash = "sha256-yb2hXa1re5rBQnAvdP5pXaOdidg85KQLrXWgz411JNM=";

  npmBuildScript = "app:build"; # Omit manual-tests:build
}
