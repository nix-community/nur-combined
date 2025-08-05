{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.12.0-unstable-2025-08-04";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "a64b359d05a60a11701724b5a8090556eac1b5da";
    hash = "sha256-oibBkZ7JxVVJSnabHGB0XNwJiYJiAdfUhp7hxTv8ArY=";
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
