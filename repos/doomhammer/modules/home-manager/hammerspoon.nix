{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.home) preferXdgDirectories;

  cfg = config.my.services.hammerspoon;
in
{
  options.my.services.hammerspoon = {
    enable = lib.mkEnableOption "Enable the hammerspoon service.";
    package = lib.mkPackageOption pkgs "hammerspoon" { };
    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
    spoons = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          (lib.hm.assertions.assertPlatform "my.services.hammerspoon" pkgs lib.platforms.darwin)
        ];

        home.packages = [ cfg.package ];

        xdg.configFile."hammerspoon/init.lua" = lib.mkIf preferXdgDirectories { source = cfg.configFile; };

        home.file.".hammerspoon/init.lua" = lib.mkIf (!preferXdgDirectories) { source = cfg.configFile; };

        launchd.agents.hammerspoon = {
          enable = true;
          config = {
            ProgramArguments = [ "${cfg.package}/Applications/Hammerspoon.app/Contents/MacOS/Hammerspoon" ];
            KeepAlive = true;
            RunAtLoad = true;
          };
        };
      }
      (lib.mkIf (builtins.length cfg.spoons > 0) (
        let
          spoons = pkgs.symlinkJoin {
            name = "spoons";
            paths = cfg.spoons;
          };
        in
        {
          xdg.configFile."hammerspoon/Spoons" = lib.mkIf preferXdgDirectories {
            source = spoons;
            recursive = true;
          };
          home.file.".hammerspoon/Spoons" = lib.mkIf (!preferXdgDirectories) {
            source = spoons;
            recursive = true;
          };
        }
      ))
      (lib.mkIf config.home.preferXdgDirectories {
        # https://github.com/Hammerspoon/hammerspoon/issues/1734
        home.activation.hammerspoon-use-xdg =
          inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ]
            ''
              /usr/bin/defaults write org.hammerspoon.Hammerspoon MJConfigFile ${config.xdg.configHome}/hammerspoon/init.lua
            '';
      })
    ]
  );
}
