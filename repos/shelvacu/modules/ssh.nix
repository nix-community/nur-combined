{
  lib,
  pkgs,
  config,
  vacuModuleType ? "nixos",
  vacuModules,
  ...
}:
let
  inherit (lib) mkOption types;
  knownHostsAddonModule =
    { config, ... }:
    {
      options = {
        sshKeys = mkOption {
          type = types.coercedTo types.str lib.singleton (types.listOf types.str);
          default = [ ];
        };
        sshUsername = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        sshPort = mkOption {
          type = types.port;
          default = 22;
        };
        sshHostname = mkOption { type = types.str; };
        sshAliases = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
      };
      config = {
        sshHostname = lib.mkDefault (
          if (config.primaryIp != null) then config.primaryIp else config.primaryName
        );
        # altNames = [ config.sshHostname ];
        sshAliases = [ config.primaryName ];
      };
    };
  knownHostsParts = lib.concatMap (
    hostMod:
    let
      knownNames = map (
        name: if hostMod.sshPort == 22 then name else "[${name}]:${toString hostMod.sshPort}"
      ) (hostMod.finalNames ++ hostMod.finalIps);
    in
    map (sshKey: lib.concatStringsSep "," knownNames + " " + sshKey) hostMod.sshKeys
  ) (builtins.attrValues config.vacu.hosts);
  knownHostsText = lib.concatStringsSep "\n" knownHostsParts;
  hostConfigParts = builtins.concatMap (
    hostMod:
    map (
      name:
      "Host ${name}\n"
      + lib.optionalString (hostMod.sshUsername != null) "  User ${hostMod.sshUsername}\n"
      + lib.optionalString (hostMod.sshHostname != name) "  HostName ${hostMod.sshHostname}\n"
      + lib.optionalString (hostMod.sshPort != 22) "  Port ${toString hostMod.sshPort}\n"
    ) hostMod.sshAliases
  ) (builtins.attrValues config.vacu.hosts);
  hostConfigText = lib.concatStringsSep "\n" hostConfigParts;
in
{
  imports = [ vacuModules.knownHosts ];
  options = {
    vacu.hosts = mkOption { type = types.attrsOf (types.submodule knownHostsAddonModule); };
    vacu.ssh.knownHostsText = mkOption {
      type = types.str;
      default = knownHostsText;
      readOnly = true;
    };
    vacu.ssh.authorizedKeys = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };
    vacu.ssh.config = mkOption { type = types.lines; };
  };
  config = {
    vacu.ssh.config = lib.mkMerge [
      (lib.mkBefore hostConfigText)
      (lib.mkAfter ''
        Host *
          User shelvacu
          GlobalKnownHostsFile ${pkgs.writeText "known_hosts" config.vacu.ssh.knownHostsText}
      '')
    ];
  }
  // lib.optionalAttrs (vacuModuleType == "nixos") {
    environment.etc."ssh/ssh_config".text = lib.mkForce config.vacu.ssh.config;
  }
  // lib.optionalAttrs (vacuModuleType == "nix-on-droid") {
    environment.etc."ssh/ssh_config".text = config.vacu.ssh.config;
  };
}
// lib.optionalAttrs (vacuModuleType == "nixos") { _class = "nixos"; }
