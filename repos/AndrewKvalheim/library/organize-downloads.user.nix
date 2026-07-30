{ config, lib, pkgs, ... }:

let
  inherit (builtins) readFile replaceStrings;
  inherit (config.home) homeDirectory;
  inherit (lib) concatStringsSep getExe getExe';
  inherit (pkgs) bash efficient-compression-tool findutils libjxl resholve unzip uutils-coreutils;

  uutils-coreutils' = uutils-coreutils.override { prefix = null; };

  globs = [
    "${homeDirectory}/.local/share/PrismLauncher/instances/*/.minecraft/screenshots/*.png"
    "${homeDirectory}/Downloads/iCloud\\ Photos.zip"
    "${homeDirectory}/Downloads/iKVM_capture.jpg"
    "${homeDirectory}/Downloads/Screen\\ Shot\\ *.png"
    "${homeDirectory}/Downloads/Screenshot\\ *.png"
    "${homeDirectory}/VirtualBox\\ VMs/*/VirtualBox_*.png" # Related: https://www.virtualbox.org/ticket/22135
  ];

  handler = resholve.writeScriptBin "organize-downloads"
    {
      interpreter = getExe bash;
      inputs = [ efficient-compression-tool findutils libjxl unzip uutils-coreutils' ];
      execer = [
        "cannot:${getExe' libjxl "cjxl"}"
        "cannot:${getExe' uutils-coreutils' "date"}"
        "cannot:${getExe' uutils-coreutils' "mkdir"}"
        "cannot:${getExe' uutils-coreutils' "mv"}"
        "cannot:${getExe' uutils-coreutils' "rm"}"
        "cannot:${getExe' uutils-coreutils' "sleep"}"
        "cannot:${getExe' uutils-coreutils' "stat"}"
        "cannot:${getExe' uutils-coreutils' "touch"}"
      ];
      keep."$handler" = true;
    }
    (replaceStrings [ "@GLOBS@" ] [ (concatStringsSep " " globs) ] (readFile ./assets/organize-downloads.sh));
in
{
  config = {
    systemd.user.paths.organize-downloads = {
      Unit.Description = "Watch downloads";
      Path.PathExistsGlob = globs;
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services.organize-downloads = {
      Unit.Description = "Organize downloads";
      Service = {
        Type = "oneshot";
        Nice = 10;
        ExecStart = getExe handler;
        KillMode = "process";
      };
    };
  };
}
