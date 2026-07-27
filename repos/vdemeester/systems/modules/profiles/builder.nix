{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption importTOML filter;
  cfg = config.profiles.externalbuilder;
  metadata = importTOML ../../../ops/hosts.toml;
  currentHostIP =
    if builtins.hasAttr "addrs" metadata.hosts.${config.networking.hostName}
    then metadata.hosts.${config.networking.hostName}.addrs.v4
    else "0.0.0.0";
  isCurrentHost = n: n.hostName != currentHostIP;
in
{
  options = {
    profiles.externalbuilder = {
      enable = mkEnableOption "Enable externalbuilder profile";
    };
  };
  config = mkIf cfg.enable {
    nix.distributedBuilds = true;
    sops.secrets.builder = {
      sopsFile = ../../../secrets/builder.yaml;
      mode = "600";
      path = "/etc/nix/builder.key";
    };

    nix.buildMachines = (filter isCurrentHost
      [
        {
          hostName = "${metadata.hosts.shikoku.addrs.v4}";
          maxJobs = metadata.hosts.shikoku.builder.maxJobs;
          sshUser = "builder";
          sshKey = config.sops.secrets.builder.path;
          systems = metadata.hosts.shikoku.builder.systems;
          supportedFeatures = metadata.hosts.shikoku.builder.features;
        }
        {
          hostName = "${metadata.hosts.aomi.addrs.v4}";
          maxJobs = metadata.hosts.aomi.builder.maxJobs;
          sshUser = "builder";
          sshKey = config.sops.secrets.builder.path;
          systems = metadata.hosts.aomi.builder.systems;
          supportedFeatures = metadata.hosts.aomi.builder.features;
        }
      ]
    );

    programs.ssh.knownHosts = {
      "shikoku" = {
        hostNames = [ "shikoku.home" "${metadata.hosts.shikoku.addrs.v4}" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH18c6kcorVbK2TwCgdewL6nQf29Cd5BVTeq8nRYUigm";
      };
      "aomi" = {
        hostNames = [ "aomi.home" "${metadata.hosts.aomi.addrs.v4}" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQVlSrUKU0xlM9E+sJ8qgdgqCW6ePctEBD2Yf+OnyME";
      };
    };

  };


}
