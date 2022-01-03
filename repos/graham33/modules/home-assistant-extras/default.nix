{config, pkgs, lib, modulesPath, ...}:

with lib;

let
  cfg = config.services.home-assistant;
in {
  options = {
    services.home-assistant.custom-components = mkOption {
      type = types.attrsOf types.package;
      default = {};
      description = "Custom components to link under /var/lib/hass/custom_components";
      example = "{ foo = pkgs.foo-custom-component; }";
    };

    services.home-assistant.config-files = mkOption {
      type = types.attrsOf types.package;
      default = {};
      description = ''
        Set of config files (store paths) to link under /var/lib/hass/, for
        example secrets.yaml, lovelace dashboard YAML files, etc.

        Note: if installing secrets.yaml, ensure it is sourced and stored
        securely.
      '';
      example = ''{ "dashboard-main.yaml" = "$\{./dashboard-main.yaml}"; }'';
    };

    services.home-assistant.static-content = mkOption {
      type = with types; nullOr package;
      default = null;
      description = "Store path to symlink as /var/lib/hass/www for static content.";
      example = ''"$\{./www}"'';
    };
  };

  config = let
    linkCommand = config-path: file: ''
        rm -f ${cfg.configDir}/${config-path} && ln -s ${file} ${cfg.configDir}/${config-path}
      '';
    customComponentFiles = lib.mapAttrs' (k: v: (nameValuePair "custom_components/${k}" "${v}/custom_components/${k}")) cfg.custom-components;

    configFilesPreStart = lib.concatStrings (lib.mapAttrsToList linkCommand cfg.config-files);
    customComponentsPreStart = lib.optionalString (cfg.custom-components != {}) (''
      # custom components
      mkdir -p ${cfg.configDir}/custom_components
    '' + lib.concatStrings (lib.mapAttrsToList linkCommand customComponentFiles));
    staticContentPreStart = lib.optionalString (cfg.static-content != null) ''
      # static content
      rm -f ${cfg.configDir}/www && ln -s ${cfg.static-content} ${cfg.configDir}/www
    '';
  in {
    systemd.services.home-assistant.preStart = configFilesPreStart + customComponentsPreStart + staticContentPreStart;
  };
}
