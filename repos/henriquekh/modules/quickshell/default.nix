{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.quickshell;
in
{
  options.programs.quickshell = {
    _class = "homeManager";
    enable = lib.mkEnableOption "quickshell";
    package = lib.mkPackageOption "quickshell" {
      nullable = false;
      default = null;
      defaultText = "null";
    };
    configFolder = lib.mkOption {
      example = "./config";
      description = "A path to a configuration for quickshell, it must contain a shell.qml file inside";
      type = lib.types.path;
    };

    extraPackages = lib.mkOption {
      default = [ ];
      example = "[ pkgs.cava ]";
      description = "A set of packages available to quickshell.";
      type = lib.types.listOf lib.types.package;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.runCommand "quickshell-wrapped"
        {
          nativeBuildinputs = [ pkgs.makeWrapper ];
        }
        ''
          mkdir -p $out/bin
          makeWrapper ${cfg.package}/bin/qs $out/bin/qs \
            --prefix QT_PLUGIN_PATH : "${pkgs.qt6.full}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
            --prefix QML2_IMPORT_PATH : "${pkgs.qt6.full}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
            --prefix PATH : ${lib.makeBinPath cfg.extraPackages}
        ''
      )
    ];
    xdg.configFile.quickshell.source = cfg.shellConfig;
  };
}
