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
  knownHostsAddonModule = { config, ... }: {
    options.ssh = {
      keys = mkOption {
        type = types.coercedTo types.str lib.singleton (types.listOf types.str);
        default = [ ];
      };
      username = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      port = mkOption {
        type = types.port;
        default = 22;
      };
      connectAddress = mkOption {
        type = types.str;
        description = "Which hostname/ip to connect to; the HostName option in ssh config.";
        default = if (config.primaryIp != null) then "${config.primaryIp}" else config.primaryName;
        defaultText = "primaryIp ?? primaryName";
      };
      aliases = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      config = mkOption {
        type = types.lines;
        default = "";
      };
    };
    config.ssh = {
      aliases = [ config.primaryName ];
      config = lib.mkMerge [
        (lib.mkIf (config.ssh.username != null) "User ${config.ssh.username}")
        (lib.mkIf (config.ssh.connectAddress != null) "HostName ${config.ssh.connectAddress}")
        (lib.mkIf (config.ssh.port != 22) "Port ${toString config.ssh.port}")
      ];
    };
  };
  knownHostsParts = lib.concatMap (
    hostMod:
    let
      knownNames = map (
        name: if hostMod.ssh.port == 22 then name else "[${name}]:${toString hostMod.ssh.port}"
      ) (hostMod.finalNames ++ hostMod.finalIps);
    in
    map (sshKey: lib.concatStringsSep "," knownNames + " " + sshKey) hostMod.ssh.keys
  ) (builtins.attrValues config.vacu.hosts);
  knownHostsText = lib.concatStringsSep "\n" knownHostsParts;
  hostConfigParts = builtins.concatMap (
    hostMod:
    map (
      name:
      "Host ${name}\n"
      + (lib.pipe hostMod.ssh.config [
        (lib.splitString "\n")
        (map lib.trim)
        (lib.filter (s: s != ""))
        (map (s: "  ${s}\n"))
        lib.concatStrings
      ])
    ) hostMod.ssh.aliases
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
