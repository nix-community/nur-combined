{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.13.1-unstable-2025-09-23";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "cba6d5ac047ad1dfc2b703adc222b6529e986954";
    hash = "sha256-jEywBTZRzCCIki84CTKQHHl1aMFfgLVpOrRcJkghvzI=";
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
