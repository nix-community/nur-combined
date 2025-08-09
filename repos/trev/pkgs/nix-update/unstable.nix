{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.12.1-unstable-2025-08-08";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "af520c7a08988620fa1d43292f9edb8ff1f82529";
    hash = "sha256-ygbAx4TV9NFjpttn+4ELT3Zfu/tiRyigO7R4WT/ntTw=";
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
