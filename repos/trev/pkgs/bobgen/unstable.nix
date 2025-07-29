{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs
(final: prev: {
  version = "0.39.0-unstable-2025-07-28";

  src = fetchFromGitHub {
    owner = "stephenafamo";
    repo = "bob";
    rev = "fd2d31aa64583c4df814b5c8705ac3bc19c00c97";
    hash = "sha256-hTf0w0rng2wIFdPDaym3zXnAsDBgM9Bkzipd7HUhF7Q=";
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
