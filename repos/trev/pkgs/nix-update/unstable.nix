{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.11.0-unstable-2025-07-21";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "a96a5c23bf09c2b3c295b789a2fd40e97f24e75c";
    hash = "sha256-SxTOXG/enF0ALdAciJEzDyUcrGP/FcWnT4NMTdfIDOo=";
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
