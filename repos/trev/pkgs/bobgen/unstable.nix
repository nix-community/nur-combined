{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs
(final: prev: {
  version = "0.39.0-unstable-2025-08-04";

  src = fetchFromGitHub {
    owner = "stephenafamo";
    repo = "bob";
    rev = "b2e9e2d2da43ee251d9e20ae7d8a87b9b01c26eb";
    hash = "sha256-Q1kCoNKHK1jowmrTvb3rMh6RBZu5WcAZYnVUd6IENR0=";
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
