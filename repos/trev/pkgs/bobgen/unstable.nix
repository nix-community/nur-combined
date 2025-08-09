{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs
(final: prev: {
  version = "0.39.0-unstable-2025-08-08";

  src = fetchFromGitHub {
    owner = "stephenafamo";
    repo = "bob";
    rev = "a12bf7ad7835b6e658e57b597c32ad6e92d72022";
    hash = "sha256-BmU+MaOy7hzzVL/CIB+Tf7aYjz7+K+NqLBj1QFcWr/4=";
  };

  vendorHash = "sha256-3K5ByPBrZRsLcmp0JMNLCcLqQdQizTdxN1Q7B4xe9vc=";

  passthru = {
    updateScript = lib.concatStringsSep " " (nix-update-script {
      extraArgs = [
        "--commit"
        "--version=branch=main"
        "${final.pname}.unstable"
      ];
    });
  };

  meta =
    prev.meta
    // {
      description = "${prev.meta.description} - main branch";
      changelog = "https://github.com/stephenafamo/bob/commits/${final.src.rev}/";
    };
})
