{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.13.0-unstable-2025-09-22";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "2caf62304f843987b44b2084aa855d1423e8a715";
    hash = "sha256-RDBz4j9x10Tv2CFcb0YTwk5m+K1aXIaUQj3qdlL8OPo=";
  };

  passthru =
    prev.passthru
    // {
      updateScript = lib.concatStringsSep " " (nix-update-script {
        extraArgs = [
          "--commit"
          "--version=branch=main"
          "${final.pname}"
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
