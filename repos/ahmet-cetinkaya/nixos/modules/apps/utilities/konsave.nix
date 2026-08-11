{pkgs, ...}: let
  acKonsaveApply = pkgs.writeShellScriptBin "ac-konsave-apply" ''
    set -euo pipefail

    echo '+ konsave -a ahmet-cetinkaya'
    exec ${pkgs.konsave}/bin/konsave -a ahmet-cetinkaya
  '';
  acKonsaveSave = pkgs.writeShellScriptBin "ac-konsave-save" ''
    set -euo pipefail

    echo '+ konsave -s ahmet-cetinkaya -f'
    exec ${pkgs.konsave}/bin/konsave -s ahmet-cetinkaya -f
  '';
in {
  environment.systemPackages = [
    pkgs.konsave
    acKonsaveApply
    acKonsaveSave
  ];
}
