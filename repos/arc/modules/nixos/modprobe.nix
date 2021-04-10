{ pkgs, config, lib, ... }: with lib; let
  # this partially exists to work around https://github.com/NixOS/nixpkgs/issues/25456
  cfg = config.boot.modprobe;
  optionString = option: value: let
    str =
      if value == true then "1"
      else if value == false then "0"
      else toString value;
  in "${option}=${str}";
  moduleType = types.submodule ({ config, name, ... }: {
    options = {
      moduleName = mkOption {
        type = types.str;
        default = name;
      };
      blacklist = mkOption {
        type = types.bool;
        default = false;
      };
      includeInInitrd = mkOption {
        type = types.bool;
        default = true;
      };
      aliases = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      installCommands = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      removeCommands = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      options = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };
      modprobeConfig = mkOption {
        type = types.lines;
        readOnly = true;
      };
    };
    config = {
      modprobeConfig = let
        aliases = map (alias: ''alias ${alias} ${config.moduleName}'') config.aliases;
        options = ''options ${config.moduleName} '' + concatStringsSep " " (mapAttrsToList optionString (filterAttrs (_: opt: opt != null) config.options));
        install = ''install ${config.moduleName} '' + concatStringsSep "; " config.installCommands;
        remove = ''remove ${config.moduleName} '' + concatStringsSep "; " config.removeCommands;
      in mkMerge ([
        (mkIf config.blacklist "blacklist ${config.moduleName}")
        (mkIf (config.options != { }) options)
        (mkIf (config.installCommands != [ ]) install)
        (mkIf (config.removeCommands != [ ]) remove)
        config.extraConfig
      ] ++ aliases);
    };
  });
in {
  options.boot.modprobe = {
    enable = mkOption {
      type = types.bool;
      default = cfg.modules != { };
    };
    modules = mkOption {
      type = types.attrsOf moduleType;
      default = { };
    };
  };
  config.boot = mkIf cfg.enable {
    initrd.prepend = singleton "${pkgs.makeInitrd {
      name = "initrd-modprobe";
      inherit (config.boot.initrd) compressor;

      contents = singleton {
        symlink = "/etc/modprobe.d/nixos-arc.conf";
        object = let
          includedModules = filter (mod: mod.includeInInitrd) (attrValues cfg.modules);
          modprobeConfig = concatMapStringsSep "\n" (mod: mod.modprobeConfig) includedModules;
        in pkgs.writeText "modprobe.conf" modprobeConfig;
      };
    }}/initrd";
    extraModprobeConfig = mkMerge (mapAttrsToList (_: mod: mod.modprobeConfig) cfg.modules);
  };
}
