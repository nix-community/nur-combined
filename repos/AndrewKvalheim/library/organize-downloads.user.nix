{ config, lib, pkgs, ... }:

let
  inherit (builtins) readFile replaceStrings;
  inherit (config.home) homeDirectory;
  inherit (config.services) organize-downloads;
  inherit (lib) concatStringsSep getExe getExe' mkOption replaceString;
  inherit (lib.types) listOf str;
  inherit (pkgs) bash efficient-compression-tool findutils gnugrep inotify-tools libjxl lsof resholve unzip uutils-coreutils;

  uutils-coreutils' = uutils-coreutils.override { prefix = null; };

  globs = map (g: "${homeDirectory}/${replaceString " " "\\ " g}") organize-downloads.globs;

  handler = resholve.writeScriptBin "organize-downloads"
    {
      interpreter = getExe bash;
      inputs = [ efficient-compression-tool findutils gnugrep inotify-tools libjxl lsof unzip uutils-coreutils' ];
      execer = [
        "cannot:${getExe' libjxl "cjxl"}"
        "cannot:${getExe' uutils-coreutils' "date"}"
        "cannot:${getExe' uutils-coreutils' "ls"}"
        "cannot:${getExe' uutils-coreutils' "mkdir"}"
        "cannot:${getExe' uutils-coreutils' "mv"}"
        "cannot:${getExe' uutils-coreutils' "rm"}"
        "cannot:${getExe' uutils-coreutils' "rmdir"}"
        "cannot:${getExe' uutils-coreutils' "sleep"}"
        "cannot:${getExe' uutils-coreutils' "stat"}"
        "cannot:${getExe' uutils-coreutils' "touch"}"
      ];
      keep."$handler" = true;
    }
    (replaceStrings [ "@GLOBS@" ] [ (concatStringsSep " " globs) ] (readFile ./assets/organize-downloads.sh));
in
{
  options.services.organize-downloads = {
    globs = mkOption { type = listOf str; default = [ ]; };
  };

  config = {
    services.organize-downloads.globs = [
      ".local/share/PrismLauncher/instances/*/.minecraft/screenshots/*.png"
      "Downloads/iCloud Photos.zip"
      "Downloads/iKVM_capture.jpg"
      "Downloads/Screen Shot *.png"
      "Downloads/Screenshot *.png"
      "VirtualBox VMs/*/VirtualBox_*.png" # Related: https://www.virtualbox.org/ticket/22135
    ];

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
