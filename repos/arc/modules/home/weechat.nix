{ config, pkgs, lib, ... }: with lib; let
  #settingType = types.attrsOf (types.attrsOf (types.attrsOf cfgType));
  settingType = types.attrsOf (types.either cfgType settingType);
  flatConfig = attrs: let
    deep = mapAttrsRecursive (path: value: nameValuePair (concatStringsSep "." path) value) attrs;
    recurse = value:
      if isAttrs value && ! value ? value then concatMap recurse (builtins.attrValues value)
      else [ value ];
  in listToAttrs (recurse deep);
  cfgType = types.either types.str (types.either types.bool types.int);
  cfg = config.programs.weechat;
  drvAttr = types.either types.str types.package;
  drvAttrsFor = packages: map (d:
    if isString d then packages.${d} else d
  );
  configStr = v:
    if isString v then ''"${v}"''
    else if isBool v then (if v then "on" else "off")
    else if isInt v then toString v
    else throw "unknown weechat config value ${toString v}";
  configure = { availablePlugins, ... }: {
    plugins = with availablePlugins;
      optional cfg.plugins.python.enable (
        python.withPackages (ps: drvAttrsFor ps cfg.plugins.python.packages)
      );
    scripts = drvAttrsFor pkgs.weechatScripts cfg.scripts;
  };
in {
  options.programs.weechat = {
    enable = mkEnableOption "weechat";

    package = mkOption {
      type = types.package;
      defaultText = "pkgs.weechat";
      default = cfg.packageWrapper cfg.packageUnwrapped { inherit configure; };
    };

    packageUnwrapped = mkOption {
      type = types.package;
      defaultText = "pkgs.weechat-unwrapped";
      default = pkgs.weechat-unwrapped.override { inherit (cfg) pythonPackages; };
    };

    packageWrapper = mkOption {
      type = types.unspecified;
      defaultText = "pkgs.wrapWeechat";
      default = pkgs.wrapWeechat.override { inherit (cfg) pythonPackages; };
    };

    pythonPackages = mkOption {
      type = types.unspecified;
      defaultText = "pkgs.pythonPackages";
      example = literalExample "pkgs.python3Packages";
      default = pkgs.pythonPackages;
    };

    plugins = {
      python = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };

        packages = mkOption {
          type = types.listOf drvAttr;
          default = [ ];
          description = "Attributes or derivations from pythonPackages that scripts might depend on";
          example = [ "weechat-matrix" ];
        };
      };
    };

    scripts = mkOption {
      type = types.listOf drvAttr;
      description = "Attributes or derivations from pkgs.weechatScripts";
      default = [ ];
      example = [ "weechat-matrix" "weechat-autosort" ];
    };

    autoconfig = mkOption {
      type = settingType;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file.".weechat/.weerc" = mkIf (cfg.autoconfig != { }) {
      text = ''
        */set plugins.var.python.autoconf.autosave off
      '' + concatStringsSep "\n" (mapAttrsToList (k: v:
        "*/set ${k} ${configStr v}"
      ) (flatConfig cfg.autoconfig));
    };
  };
}
