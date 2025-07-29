{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.11.0-unstable-2025-07-29";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "837d91abbef68e95a54107ccc6f0ecd597c34002";
    hash = "sha256-nsN5b1JgbnqAR6B3m98aPQjOWTQ4jjbM5sSb1dtvIoU=";
  };

  passthru =
    prev.passthru
    // {
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
      changelog = "https://github.com/Mic92/nix-update/commits/${final.src.rev}/";
    };
})
