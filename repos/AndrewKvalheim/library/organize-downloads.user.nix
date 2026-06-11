{ lib, pkgs, ... }:

let
  inherit (builtins) readFile;
  inherit (lib) getExe getExe';
  inherit (pkgs) bash efficient-compression-tool findutils resholve uutils-coreutils;

  uutils-coreutils' = uutils-coreutils.override { prefix = null; };

  handler = resholve.writeScriptBin "organize-downloads" {
    interpreter = getExe bash;
    inputs = [ efficient-compression-tool findutils uutils-coreutils' ];
    execer = [
      "cannot:${getExe' uutils-coreutils' "mkdir"}"
      "cannot:${getExe' uutils-coreutils' "mv"}"
      "cannot:${getExe' uutils-coreutils' "sleep"}"
      "cannot:${getExe' uutils-coreutils' "tail"}"
    ];
  } (readFile ./assets/organize-downloads.sh);
in
{
  config = {
    systemd.user.paths.organize-downloads = {
      Unit.Description = "Watch downloads";
      Path.PathExistsGlob = [
        "%h/.local/share/PrismLauncher/instances/*/.minecraft/screenshots/*.png"
        "%h/Downloads/Screen{s,\\ S}hot\\ *.png"
        "%h/VirtualBox\\ VMs/*/VirtualBox_*.png" # Related: https://www.virtualbox.org/ticket/22135
      ];
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services.organize-downloads = {
      Unit.Description = "Organize downloads";
      Service.ExecStart = getExe handler;
      Service.Nice = 10;
    };
  };
}
