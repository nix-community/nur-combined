{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.13.1-unstable-2025-10-06";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "116ba224b637f77a5c1b6baa344bec6d8e317d2c";
    hash = "sha256-2eJH4rMvmiQqzeZkY0RXi8zoJYS/I6JMOoANZqj68x0=";
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
