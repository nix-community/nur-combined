{
  lib,
  config,
  vacuModuleType ? "nixos",
  vaculib,
  ...
}:
let
  inherit (lib) mkOption types;
  nameishRegex = ''[a-z0-9_\.-]+'';
  nameish = types.strMatching nameishRegex;
  hostModule =
    { name, config, ... }:
    let
      fullLanNames = lib.optional (config.isLan) "${config.primaryName}.t2d.lan";
    in
    {
      options = {
        primaryName = mkOption {
          type = nameish;
          default = name;
        };
        altNames = mkOption {
          type = types.listOf nameish;
          default = [ ];
        };
        isLan = mkOption {
          type = types.bool;
          default = false;
        };
        finalNames = mkOption {
          type = types.listOf nameish;
          readOnly = true;
        };
        primaryIp = mkOption {
          type = types.nullOr vaculib.ip.type;
          default = null;
        };
        altIps = mkOption {
          type = types.listOf vaculib.ip.type;
          default = [ ];
        };
        finalIps = mkOption {
          type = types.listOf vaculib.ip.type;
          readOnly = true;
        };
        makeStaticHostsEntry = mkOption { type = types.bool; };
        wireguardKey = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
      config = {
        finalNames = lib.unique ([ config.primaryName ] ++ config.altNames ++ fullLanNames);
        finalIps = lib.unique ((lib.optional (config.primaryIp != null) config.primaryIp) ++ config.altIps);
        makeStaticHostsEntry = lib.mkDefault (config.primaryIp != null);
      };
    };
  hostsFileEntryModule = { name, config, ... }: {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      names = mkOption {
        type = types.listOf nameish;
        default = [ name ];
      };
      ip = mkOption { type = vaculib.ip.type; };
    };
  };
in
{
  options.vacu = {
    hosts = mkOption {
      type = types.attrsOf (types.submodule hostModule);
      default = { };
    };
    hostsFile = {
      entries = mkOption {
        type = types.attrsOf (types.submodule hostsFileEntryModule);
        default = { };
      };
      text = mkOption {
        type = types.str;
        readOnly = true;
        defaultText = "(output)";
      };
    };
  };
  config = {
    vacu.hostsFile.entries = lib.pipe config.vacu.hosts [
      builtins.attrValues
      (builtins.filter (cfg: cfg.makeStaticHostsEntry))
      (map (
        cfg:
        assert cfg.primaryIp != null;
        lib.nameValuePair (builtins.head cfg.finalNames) {
          names = cfg.finalNames;
          ip = cfg.primaryIp;
        }
      ))
      builtins.listToAttrs
    ];
    vacu.hostsFile.text =
      let
        configs = lib.pipe config.vacu.hostsFile.entries [
          builtins.attrValues
          (builtins.filter (cfg: cfg.enable))
        ];
        longestIp = lib.pipe configs [
          (map (cfg: builtins.stringLength "${cfg.ip}"))
          vaculib.listMaxNonEmpty
        ];
      in
      if configs == [ ] then
        ""
      else
        lib.pipe configs [
          (map (
            cfg:
            "${
              vaculib.lJustify {
                totalLength = longestIp;
                errorOnLonger = true;
              } cfg.ip
            } ${lib.concatStringsSep " " cfg.names}\n"
          ))
          lib.concatStrings
        ];
  }
  // lib.optionalAttrs (vacuModuleType == "nixos") {
    networking.extraHosts = config.vacu.hostsFile.text;
  }
  // lib.optionalAttrs (vacuModuleType == "nix-on-droid") {
    environment.etc.hosts.text = config.vacu.hostsFile.text;
  };
}
