{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.11.0-unstable-2025-08-02";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "041496ef081c84c633ab04a9171c6addfc2d4e9d";
    hash = "sha256-sgSffk3wWQQuezIHORU9EFY7IajOhQm/DlHps+SkMAI=";
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
