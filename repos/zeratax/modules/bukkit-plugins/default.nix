{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.bukkit-plugins;

  serviceConfig = {
    Type = "simple";
    User = "minecraft";
    WorkingDirectory = cfg.pluginsDir;
  };

  bukkitPlugin = import ./bukkit-plugin.nix {
    inherit lib pkgs;
    systemConfig = config;
  };
  mkService = name: opts:
    with opts;
    let
      settingsFormat = pkgs.formats.yaml { };
      settingsFiles = mapAttrs' (n: v:
        nameValuePair "${cfg.pluginsDir}/${n}"
        (settingsFormat.generate "${n}" v)) settings;
      settingsCommands = mapAttrsToList (n: v: ''
        mkdir -p `dirname ${n}`
        ln -sf ${v} ${n}
      '') settingsFiles;
    in {
      inherit serviceConfig;
      description = "A bukkit plugin service for ${name}.";

      wantedBy = [ "multi-user.target" ];

      wants = [ "bukkit-plugins.service" ];
      after = [ "bukkit-plugins.service" ];
      before = [ "minecraft-server.service" ];

      environment = { DIR = cfg.pluginsDir; };

      preStart = ''
        pluginJar=`ls -1 ${package}/share/*.jar | head -1`
        ln -sf $pluginJar ${cfg.pluginsDir}/${name}.jar
        ${concatStringsSep "\n" settingsCommands}
      '';

      script = ''
        ${prepareScript}
      '';
    };

in {
  options = {
    services.bukkit-plugins = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If enabled, places the plugins and associated config files in the
          <option>services.bukkit-plugins.pluginsDir</option>.
        '';
      };

      pluginsDir = mkOption {
        type = types.path;
        default = "${config.services.minecraft-server.dataDir}/plugins";
        description = ''
          Plugins directory of the minecraft server
        '';
      };

      plugins = mkOption {
        type = types.attrsOf bukkitPlugin;
        default = { };
        example = literalExample ''
          {
            harbor = {
              package = pkgs.bukkit-plugins.harbor;
              settings = {
                "Harbor/config.yml" = {
                  blacklist = [
                    "world_nether"
                    "world_the_end"
                  ]
                }
              };
            };
          }
        '';
        description = ''
          Bukkit plugins to add to your server
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      systemd.services =
        mapAttrs' (n: v: nameValuePair "bukkit-plugin-${n}" (mkService n v))
        cfg.plugins;
    }

    {
      systemd.services.bukkit-plugins = {
        description =
          "service to prepare the plugins directory for other bukkit plugins";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = let
          # findExceptions = concatStringsSep " " mapAttrsToList (n: v: "! -name ${n}.jar") cfg.plugins;
          deletePluginJars = pkgs.writeScriptBin "deletePluginJars" ''
            #!${pkgs.stdenv.shell}
            rm -f ${cfg.pluginsDir}/*.jar
          '';
        in {
          # delete all symlinked jars before and after every start
          # to make sure no disabled plugins will be loaded
          RemainAfterExit = true;
          ExecStart = "${deletePluginJars}/bin/deletePluginJars";
          ExecStop = "${deletePluginJars}/bin/deletePluginJars";
        } // serviceConfig;
      };
    }
  ]);
}
