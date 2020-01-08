{ pkgs, config, lib, ... }: with lib; let
  cfg = config.programs.firefox.tridactyl;
  cmdType = types.str; # TODO: add fancier types for "js" etc that escape things and compose better
  settingType = types.either types.bool types.str;
  configStrs = {
    cmd = cmd: cmd;
    alias = name: cmd: "alias ${name} ${configStrs.cmd cmd}";
    settingValue = value:
      if isBool value then (if value then "true" else "false")
      else value;
    setting = name: value: "set ${name} ${configStrs.settingValue value}";
    urlSettings = name: list: concatStringsSep "\n" (map (value:
      "seturl ${value.urlPattern} ${name} ${configStrs.settingValue value.value}"
    ) (attrValues list));
    urlPattern = url:
      if url == null then ".*" else url;
    autocmdName = name: (toUpper (substring 0 1 name)) + substring 1 (stringLength name) name;
    autocmds = name: list: concatStringsSep "\n" (map (value:
      "autocmd ${configStrs.autocmdName name} ${configStrs.urlPattern value.urlPattern} ${configStrs.cmd value.cmd}"
    ) list);
    autocontain = { urlPattern, container, isDomainPattern, ... }:
      "autocontain${optionalString (!isDomainPattern) " -u"} ${urlPattern} ${if container == null then throw "default container unimplemented" else container}";
    keyseq = mods: key: let
      modStr = concatStrings (map (mod: {
        alt = "A";
        ctrl = "C";
        meta = "M";
        shift = "S";
      }.${mod}) (toList mods));
      escapedKey = mapNullable head (builtins.match "<(.*)>" key);
      strippedKey = if escapedKey == null then key else escapedKey;
    in if mods == []
      then key
      else "<${modStr}-${strippedKey}>";
    bindingLine = config: mode: let
      cmd = "${optionalString (config.cmd == null) "un"}bind${optionalString (config.urlPattern != null) "url"}";
      cmdStr = optionalString (config.cmd != null) " ${config.cmd}";
      in if config.urlPattern != null
        then "${cmd} ${config.urlPattern} ${mode} ${config.binding}${cmdStr}"
        else "${cmd}${optionalString (mode != "normal") " --mode=${mode}"} ${config.binding}${cmdStr}";
    binding = config:
      concatStringsSep "\n" (map (configStrs.bindingLine config) (toList config.mode));
  };
in {
  options.programs.firefox.tridactyl = {
    enable = mkEnableOption "tridactyl Firefox plugin";
    themes = mkOption {
      description = "tridactyl theme data";
      type = types.attrsOf (types.either types.lines types.path);
      default = { };
    };

    bindings = mkOption {
      default = { };
      type = types.loaOf (types.submodule ({ config, ... }: {
        options = {
          urlPattern = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Restrict keybinding to pages that match a regex pattern";
          };

          mode = mkOption {
            type = let
              ty = types.enum [ "normal" "ex" "input" "insert" "ignore" "hint" ];
            in types.either ty (types.listOf ty);
            default = "normal";
          };

          key = mkOption {
            type = types.str;
          };

          mods = mkOption {
            type = let
              ty = types.enum [ "alt" "ctrl" "meta" "shift" ];
            in types.either ty (types.listOf ty);
            default = [ ];
          };

          cmd = mkOption {
            type = types.nullOr cmdType;
          };

          binding = mkOption {
            type = types.str;
            default = configStrs.keyseq config.mods config.key;
          };
        };
      }));
    };

    exalias = mkOption {
      type = types.attrsOf cmdType;
      default = { };
    };

    settings = mkOption {
      type = types.attrsOf settingType;
      default = { };
    };

    urlSettings = mkOption {
      default = { };
      type = types.attrsOf (types.loaOf (types.submodule ({ name, ... }: {
        options = {
          urlPattern = mkOption {
            type = types.str;
            default = name;
          };

          value = mkOption {
            type = settingType;
          };
        };
      })));
    };

    sanitise = {
      local = mkOption {
        type = types.bool;
        default = false;
      };

      sync = mkOption {
        type = types.bool;
        default = false;
      };

      excmd = mkOption {
        type = types.str;
        internal = true;
        default = concatStringsSep " " [
          "sanitise"
          (optionalString cfg.sanitise.local "tridactyllocal")
          (optionalString cfg.sanitise.sync "tridactylsync")
        ] + optionalString (cfg.settings ? storageloc) "\n${configStrs.setting "storageloc" cfg.settings.storageloc}";
      };
    };

    autocontain = mkOption {
      description = "Automatically open a domain in a specified container";
      default = { };
      type = types.loaOf (types.submodule ({ name, ... }: {
        options = {
          urlPattern = mkOption {
            type = types.str;
            default = name;
          };

          isDomainPattern = mkOption {
            type = types.bool;
            default = true;
          };

          container = mkOption {
            type = types.nullOr types.str;
          };
        };
      }));
    };

    autocmd = let
      auType = types.submodule ({ ... }: {
        options = {
          urlPattern = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Regex pattern of url to match, or null to trigger always";
          };

          cmd = mkOption {
            type = cmdType;
            description = "Command to run when the event triggers.";
          };
        };
      });
      type = types.listOf auType;
      default = [ ];
    in {
      triStart = mkOption {
        inherit type default;
        description = "Commands to run when the browser starts";
      };

      docStart = mkOption {
        inherit type default;
        description = "Commands to run when a page begins to load (DocStart)";
      };

      docLoad = mkOption {
        inherit type default;
        description = "Commands to run when a page is loaded (DOMContentLoaded)";
      };

      docEnd = mkOption {
        inherit type default;
        description = "Commands to run when a page is left (pagehide event)";
      };

      tabEnter = mkOption {
        inherit type default;
        description = "Commands to run when a tab is focused";
      };

      tabLeft = mkOption {
        inherit type default;
        description = "Commands to run when a tab is left";
      };

      fullscreenEnter = mkOption {
        inherit type default;
        description = "Commands to run when fullscreen mode is entered";
      };

      fullscreenLeft = mkOption {
        inherit type default;
        description = "Commands to run when fullscreen mode is left";
      };

      fullscreenChange = mkOption {
        inherit type default;
        description = "Commands to run when fullscreen mode is changed";
      };
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    programs.firefox.tridactyl.extraConfig = mkMerge [
      (mkIf (cfg.sanitise.local || cfg.sanitise.sync) (mkBefore cfg.sanitise.excmd))
      (mkIf (cfg.exalias != { }) (concatStringsSep "\n" (mapAttrsToList configStrs.alias cfg.exalias)))
      (mkIf (cfg.autocmd != { }) (concatStringsSep "\n" (mapAttrsToList configStrs.autocmds cfg.autocmd)))
      (mkIf (cfg.autocontain != { }) (concatStringsSep "\n" (mapAttrsToList (_: configStrs.autocontain) cfg.autocontain)))
      (mkIf (cfg.settings != { }) (concatStringsSep "\n" (mapAttrsToList configStrs.setting (builtins.removeAttrs cfg.settings ["storageloc"]))))
      (mkIf (cfg.urlSettings != { }) (concatStringsSep "\n" (mapAttrsToList configStrs.urlSettings cfg.urlSettings)))
      (mkIf (cfg.bindings != { }) (concatStringsSep "\n" (mapAttrsToList (_: configStrs.binding) cfg.bindings)))
    ];
    # TODO: programs.firefox.enableTridactylNative = true;
    # TODO: implement fixamo and guiset via firefox module's profile settings
    # see also: https://github.com/tridactyl/tridactyl/blob/master/src/lib/css_util.ts
    # TODO: set this per profile instead of globally? can we use user.js to set up storage and tell tridactyl what to load on startup..? or even just fill storage instead of requiring the native extension for tridactylrc loading at all.
    xdg.configFile = {
      "tridactyl/tridactylrc".text = cfg.extraConfig;
    } // mapAttrs' (name: source: nameValuePair
      "tridactyl/themes/${name}.css" { source = pkgs.lib.asFile "${name}.css" source; }
    ) cfg.themes;
  };
}
