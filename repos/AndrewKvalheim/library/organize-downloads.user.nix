{ config, lib, pkgs, ... }:

let
  inherit (builtins) readFile replaceStrings;
  inherit (config.home) homeDirectory;
  inherit (config.services) organize-downloads;
  inherit (lib) concatStringsSep getExe getExe' mkOption replaceString;
  inherit (lib.types) listOf str;
  inherit (pkgs) bash efficient-compression-tool findutils gnugrep inotify-tools libjxl lsof on-mains-power resholve unzip uutils-coreutils-noprefix;

  globs = map (g: "${homeDirectory}/${replaceString " " "\\ " g}") organize-downloads.globs;

  handler = resholve.writeScriptBin "organize-downloads"
    {
      interpreter = getExe bash;
      inputs = [
        efficient-compression-tool
        findutils
        gnugrep
        inotify-tools
        libjxl
        lsof
        on-mains-power
        unzip
        uutils-coreutils-noprefix
      ];
      execer = [
        "cannot:${getExe' libjxl "cjxl"}"
        "cannot:${getExe' uutils-coreutils-noprefix "date"}"
        "cannot:${getExe' uutils-coreutils-noprefix "ls"}"
        "cannot:${getExe' uutils-coreutils-noprefix "mkdir"}"
        "cannot:${getExe' uutils-coreutils-noprefix "mv"}"
        "cannot:${getExe' uutils-coreutils-noprefix "rm"}"
        "cannot:${getExe' uutils-coreutils-noprefix "rmdir"}"
        "cannot:${getExe' uutils-coreutils-noprefix "sleep"}"
        "cannot:${getExe' uutils-coreutils-noprefix "stat"}"
        "cannot:${getExe' uutils-coreutils-noprefix "touch"}"
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
