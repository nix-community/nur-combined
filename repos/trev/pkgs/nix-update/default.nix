{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.13.1-unstable-2025-10-19";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "412ac9f94ce79980562cdaff362cc41da5b531bb";
    hash = "sha256-oiX56IEoI7GWrO7irKPo5LvABc/CFTVz0XDhydfdS5g=";
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
