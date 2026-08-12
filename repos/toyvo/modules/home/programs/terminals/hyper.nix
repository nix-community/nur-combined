{
  config,
  lib,
  pkgs,
  system,
  ...
}:
let
  cfg = config.programs.hyper;
in
{
  options.programs.hyper = {
    enable = lib.mkEnableOption "Hyper terminal emulator";
    package = lib.mkOption {
      type = lib.types.package;
      default = if (system == "x86_64-linux") then pkgs.hyper else pkgs.emptyDirectory;
    };
    config_file = lib.mkOption {
      type = lib.types.lines;
      default = ''
        module.exports = {
          config: {
            shell: '${lib.getExe pkgs.powershell}',
            shellArgs: ['-Nologo'],
            bell: false,
          },
        };
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.file.".hyper.js" = lib.mkIf pkgs.stdenv.isDarwin { text = cfg.config_file; };
    xdg.configFile."Hyper/.hyper.js" = lib.mkIf pkgs.stdenv.isLinux { text = cfg.config_file; };
  };
}
