{pkgs, ...}: let
  acNixApply = pkgs.writeShellScriptBin "ac-nix-apply" ''
    set -euo pipefail

    exec ${./../../../scripts/apply.sh} "$@"
  '';
  acNixUpdate = pkgs.writeShellScriptBin "ac-nix-update" ''
    set -euo pipefail

    exec ${./../../../scripts/update.sh} "$@"
  '';
  acNixCleanup = pkgs.writeShellScriptBin "ac-nix-cleanup" ''
    set -euo pipefail

    exec ${./../../../scripts/cleanup.sh} "$@"
  '';
in {
  environment.systemPackages = [acNixApply acNixUpdate acNixCleanup];
}
