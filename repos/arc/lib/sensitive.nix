{ lib }: with lib; let
  sensitiveModule = { config, options, pkgs, name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = name;
      };
      format = mkOption {
        type = types.enum [ "json" "yaml" ];
        default = "json";
      };
      settings = mkOption {
        type = json.types.attrs;
        default = { };
      };
      sensitiveSettings = mkOption {
        type = json.types.attrs;
      };
      sensitivePath = mkOption {
        type = types.path;
      };
      hasSensitive = mkOption {
        type = types.bool;
        default = options.sensitivePath.isDefined || options.sensitiveSettings.isDefined;
      };
      combineScript = mkOption {
        type = types.lines;
      };
      combinedPath = mkOption {
        type = types.path;
        default = "/run/sensitive/${config.name}.${config.format}";
      };
      owner = mkOption {
        type = types.str;
      };
      path = mkOption {
        type = types.path;
        readOnly = true;
      };
      out = {
        settingsFile = mkOption {
          type = types.path;
        };
        allSettings = mkOption {
          type = json.types.attrs;
        };
        combineScript = mkOption {
          type = types.path;
        };
        generate = mkOption {
          type = types.path;
        };
        activationScript = mkOption {
          type = types.unspecified;
        };
      };
    };
    config = {
      combineScript = let
        jq = if config.format == "yaml" then "${pkgs.yq}/bin/yq --yaml-output" else "${pkgs.jq}/bin/jq";
      in mkMerge [
        (mkBefore ''
          set -eu
          ARG_SETTINGS="$1"
          ARG_SENSITIVE="$2"
        '') ''
          COMBINE=("$ARG_SETTINGS" "$ARG_SENSITIVE")
        '' (mkAfter ''
          ${jq} -Mcs 'reduce .[] as $i ({}; . * $i)' "''${COMBINE[@]}"
        '')
      ];
      path = if config.hasSensitive then config.combinedPath else config.out.settingsFile;
      out = {
        settingsFile = "${pkgs.writeText "${config.name}.${config.format}" (builtins.toJSON config.settings)}";
        allSettings = recursiveUpdate config.settings (optionalAttrs options.sensitiveSettings.isDefined config.sensitiveSettings);
        combineScript = "${pkgs.writeShellScript "${config.name}.sh" config.combineScript}";
        generate = if config.hasSensitive then pkgs.writeShellScript "${config.name}.sh" ''
          ${config.out.combineScript} ${config.out.settingsFile} ${config.sensitivePath} > ${config.combinedPath}
        '' else "${pkgs.coreutils}/bin/true";
        activationScript = {
          deps = [ "specialfs" ];
          text = optionalString config.hasSensitive ''
            install -Dm0750 -o ${config.owner} /dev/null ${config.combinedPath}
            ${config.out.generate}
          '';
        };
      };
    };
  };
  sensitiveType = types.submodule sensitiveModule;
in {
  module = sensitiveModule;
  type = sensitiveType;
  evaluate = config: (evalModules {
    modules = [
      sensitiveModule
      config
    ];

    specialArgs = { };
  }).config;
}
