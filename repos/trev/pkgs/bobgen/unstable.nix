{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs
(final: prev: {
  version = "0.38.0-unstable-2025-07-24";

  src = fetchFromGitHub {
    owner = "stephenafamo";
    repo = "bob";
    rev = "dd16525bdd3b929c4f138cdeaba287223d1d75ff";
    hash = "sha256-V2D7ITTYGzO/+Gzqo26poDhyaiTOeBzg3rgYcn9hkXM=";
  };

  vendorHash = "sha256-tCkGffOdIm8lP/iXDji7OFVTztW9Dd1cqx5xsE2QYtU=";

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
