{ lib, pkgs, ... }:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;
  inherit (pkgs) bash coreutils efficient-compression-tool findutils resholve;

  handler = resholve.writeScriptBin "organize-downloads" {
    interpreter = getExe bash;
    inputs = [ coreutils efficient-compression-tool findutils ];
  } (readFile ./resources/organize-downloads);
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
      Service.ExecStart = "${handler}/bin/organize-downloads";
      Service.Nice = 10;
    };
  };
}
