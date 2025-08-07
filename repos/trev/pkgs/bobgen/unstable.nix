{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs
(final: prev: {
  version = "0.39.0-unstable-2025-08-06";

  src = fetchFromGitHub {
    owner = "stephenafamo";
    repo = "bob";
    rev = "c893d7d53f5eb5606003a475bfd3852c7d2fb525";
    hash = "sha256-jOUVjtGV0KW88T9uaOgJMVHGkKpl+kqh4K3C2SwbQxQ=";
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
