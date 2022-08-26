{ config, lib, ... }: with lib; let
  primary = {
    balloon = {
      name = "type";
    };
    machine = {
      implicit = true;
      setting = "type";
      name = "name";
    };
    cpu.name = "model";
    smp = {
      implicit = true;
      optional = true;
      setting = "cpus";
      name = "n";
      type = types.int;
    };
    m = {
      implicit = true;
      setting = "size";
      name = "megs";
      type = types.int;
    };
    smbios = {
      setting = "type";
      type = types.int;
    };
    mon = {
      implicit = true;
      setting = "chardev";
      name = "name";
    };
    netdev.name = "type";
    net.name = "type";
    vnc.name = "display";
    device.name = "driver";
    virtfs.name = "fsdriver";
    object.name = "typename";
    chardev.name = "backend";
    audiodev.name = "backend";
    tpmdev.name = "backend";
  };
  arclib = import ../../lib { inherit lib; };
  unmerged = lib.unmerged or arclib.unmerged;
  empty = [ ];
  nullOrEmpty = types.enum [ null empty ];
  primitiveType = with types; oneOf [ bool int str nullOrEmpty ];
  escapeString = replaceStrings [ "," ] [ ",," ];
  mapValue = value:
    if value == true then "on"
    else if value == false then "off"
    else if isString value then escapeString value
    else toString value;
  valueType = types.nullOr primitiveType;
  settingsType = types.submodule ({ ... }: {
    freeformType = types.attrsOf valueType;
  });
  argumentModule = { name, config, arg, ... }: {
    options = {
      enable = mkOption {
        type = types.bool;
      };
      settings = mkOption {
        type = settingsType;
        default = { };
      };
      cli = mkOption {
        type = unmerged.type;
      };
    };
    config = {
      cli = {
        enable = mkDefault config.enable;
        name = mkDefault arg.name;
        settings = mapAttrs (_: mkOptionDefault) config.settings;
      };
    };
  };
  objectModule = { name, config, ... }: {
    options = {
      id = mkOption {
        type = types.nullOr types.str;
        default = config.settings.id;
        readOnly = true;
      };
    };
    config = {
      settings.id = mkOptionDefault name;
    };
  };
  argumentType = { name, object ? true, isOptional ? false, modules ? [ ] }: let
    hasPrimary = primary ? ${name};
    arg = primary.${name};
    arg'name = arg.setting or arg.name;
    arg'type = arg.type or primitiveType;
    arg'optional = arg.optional or false;
    settingsModule' = { ... }: {
      options.${arg'name} = mkOption {
        type = if arg'optional || isOptional then types.nullOr arg'type else arg'type;
        ${if arg'optional || isOptional then "default" else null} = null;
      };
    };
    settingsModule = { config, options, ... }: {
      options = {
        ${if hasPrimary then "settings" else null} = mkOption {
          type = types.submodule settingsModule';
        };
      };
      config.enable = mkOptionDefault (
        if ! isOptional then true
        else if arg'optional then filterAttrs (_: v: v != null) config.settings != { }
        else config.settings.${arg'name} != null
      );
    };
    type = types.submoduleWith {
      modules = [
        argumentModule
        settingsModule
      ] ++ optional object objectModule
      ++ modules;
      specialArgs = {
        arg = {
          inherit name;
        };
      };
    };
  in type;
  cliNameModule = { config, ... }: {
    options = {
      name = mkOption {
        type = types.str;
      };
      primary = {
        name = mkOption {
          type = types.str;
          default = config.primary.setting;
        };
        setting = mkOption {
          type = types.str;
          default = "";
        };
        settingName = mkOption {
          type = types.str;
          default = if config.primary.setting == "" then config.primary.name else config.primary.setting;
        };
        implicit = mkOption {
          type = types.bool;
          default = config.primary.setting == "";
        };
        explicit = mkOption {
          type = types.bool;
          default = !config.primary.implicit && config.primary.setting != "";
        };
      };
    };
    config.primary = let
      attrs = removeAttrs primary.${config.name} or { } [ "optional" "type" ];
    in mkIf (primary ? ${config.name}) (mapAttrs (_: mkDefault) attrs);
  };
  cliNameType = types.submodule cliNameModule;
  cliArgumentType = { name, config, ... }: {
    options = {
      enable = mkEnableOption "flag" // {
        default = true;
      };
      name = mkOption {
        type = with types; coercedTo str (name: { inherit name; }) cliNameType;
        default = name;
      };
      settings = mkOption {
        type = types.nullOr settingsType;
        default = { };
      };
      value = mkOption {
        type = with types; nullOr str;
      };
      order = mkOption {
        type = types.int;
        default = 0;
      };
    };
    config.value = let
      args = removeAttrs config.settings [ config.name.primary.settingName ];
      primaryValue = mapValue config.settings.${config.name.primary.settingName};
      primaryKey = optionalString config.name.primary.explicit "${config.name.primary.setting}=";
      args' = optional (config.settings.${config.name.primary.settingName} or null != null) (primaryKey + primaryValue)
      ++ mapAttrsToList (key: value:
        key + optionalString (value != empty) "=${mapValue value}"
      ) (filterAttrs (_: v: v != null) args);
    in mkOptionDefault (if config.settings == null then null else concatStringsSep "," args');
  };
  cpuModule = { config, ... }: {
    options = {
      flags = mkOption {
        type = with types; attrsOf (oneOf [ bool (enum [ null empty ])]);
        default = { };
      };
    };
    config = {
      cli.settings = mapAttrs' (flag: value:
        nameValuePair (if value == false then "-${flag}" else if value == true then "+${flag}" else flag)
          (if value == null then null else empty)
      ) config.flags;
    };
  };
  objectsOptions = {
    devices.name = "device";
    objects.name = "object";
    audiodevs.name = "audiodev";
    netdevs.name = "netdev";
    chardevs.name = "chardev";
    monitors.name = "mon";
    drives.name = "drive";
    smbios = {
      name = "smbios";
      object = false;
    };
  };
  filteredObjects = id;
  mapObjects = mapAttrs' (key: obj: let
    id = obj.settings.id or null;
  in nameValuePair (if id != null then id else key) (unmerged.merge obj.cli));
  objectsModule = { config, ... }: {
    options = mapAttrs (key: arg: mkOption {
      type = types.attrsOf (argumentType arg);
      default = { };
    }) objectsOptions;
    config = {
      cli = mkMerge (mapAttrsToList (key: _: mapObjects config.${key}) objectsOptions);
    };
  };
  globalsModule = { config, ... }: let
    cfg = config.globals;
    globals = flatten (mapAttrsToList (ns: values: mapAttrsToList (name: value:
      nameValuePair "${ns}.${name}" value
    ) (filterAttrs (_: global: global != null) values)) cfg);
    cli = mapAttrs (name: value: {
      name = "global";
      settings.${name} = value;
    }) (listToAttrs globals);
  in {
    options = {
      globals = mkOption {
        type = types.attrsOf (types.attrsOf primitiveType);
        default = { };
      };
    };
    config = {
      inherit cli;
    };
  };
  flagsModule = { config, ... }: let
    cli = mapAttrs' (name: value: nameValuePair "arg-${name}" {
      inherit name;
      enable = value != null;
      settings = if value == empty then null else {
        "" = value;
      };
    }) config.args;
  in {
    options = {
      flags = mkOption {
        type = with types; attrsOf bool;
        default = { };
      };
      args = mkOption {
        type = settingsType;
        default = { };
      };
    };
    config = {
      args = mapAttrs (name: _: empty) (filterAttrs (_: flag: flag == true) config.flags);
      inherit cli;
    };
  };
in {
  imports = [ objectsModule globalsModule flagsModule ];
  options = {
    machine = mkOption {
      type = argumentType { name = "machine"; object = false; isOptional = true; };
      default = { };
    };
    cpu = mkOption {
      type = argumentType { name = "cpu"; object = false; modules = [ cpuModule ]; isOptional = true; };
      default = { };
    };
    smp = mkOption {
      type = argumentType { name = "smp"; object = false; isOptional = true; };
      default = { };
    };
    cli = mkOption {
      type = types.attrsOf (types.submodule cliArgumentType);
      default = { };
    };
  };
  config = {
    cli = {
      cpu = mkIf config.cpu.enable (unmerged.merge config.cpu.cli);
      machine = mkIf config.machine.enable (unmerged.merge config.machine.cli);
      smp = mkIf config.smp.enable (unmerged.merge config.smp.cli);
    };
  };
}
