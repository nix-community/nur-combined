{
  lib,
  config,
  vacuModuleType ? "nixos",
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
          type = types.nullOr nameish;
          default = null;
        };
        altIps = mkOption {
          type = types.listOf nameish;
          default = [ ];
        };
        finalIps = mkOption {
          type = types.listOf nameish;
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
  etcHostsText = lib.pipe config.vacu.hosts [
    builtins.attrValues
    (builtins.filter (cfg: cfg.makeStaticHostsEntry))
    (map (
      cfg:
      assert cfg.primaryIp != null;
      "${cfg.primaryIp} ${lib.concatStringsSep " " cfg.finalNames}"
    ))
    (lib.concatStringsSep "\n")
  ];
in
{
  options.vacu = {
    hosts = mkOption {
      type = types.attrsOf (types.submodule hostModule);
      default = { };
    };
    etcHostsText = mkOption {
      type = types.str;
      readOnly = true;
      default = etcHostsText;
      defaultText = "(output)";
    };
  };
  config =
    { }
    // lib.optionalAttrs (vacuModuleType == "nixos") {
      networking.extraHosts = config.vacu.etcHostsText;
    }
    // lib.optionalAttrs (vacuModuleType == "nix-on-droid") {
      environment.etc.hosts.text = config.vacu.etcHostsText;
    };
}
// lib.optionalAttrs (vacuModuleType == "nixos") { _class = "nixos"; }
