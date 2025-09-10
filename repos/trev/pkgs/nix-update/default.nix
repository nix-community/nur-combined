{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.12.1-unstable-2025-08-18";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "d44f8b524ccea0243009eb07ef4b995734cddbb4";
    hash = "sha256-t7GxxO8Q/sBdhN5n914MQwwKjI52mhnIm3V3vFInNEk=";
  };

  patches = [
    ./433.diff
  ];

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
