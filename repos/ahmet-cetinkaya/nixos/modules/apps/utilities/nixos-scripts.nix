{pkgs, ...}: let
  # Resolve the NixOS config directory at build time
  nixosConfigDir = ./../../..;
  
  acNixApply = pkgs.writeShellScriptBin "ac-nix-apply" ''
    set -euo pipefail
    export NIXOS_CONFIG_DIR="${nixosConfigDir}"
    exec ${./../../../scripts/apply.sh} "$@"
  '';
  acNixUpdate = pkgs.writeShellScriptBin "ac-nix-update" ''
    set -euo pipefail
    export NIXOS_CONFIG_DIR="${nixosConfigDir}"
    exec ${./../../../scripts/update.sh} "$@"
  '';
  acNixCleanup = pkgs.writeShellScriptBin "ac-nix-cleanup" ''
    set -euo pipefail
    export NIXOS_CONFIG_DIR="${nixosConfigDir}"
    exec ${./../../../scripts/cleanup.sh} "$@"
  '';
in {
  environment.systemPackages = [acNixApply acNixUpdate acNixCleanup];
}
