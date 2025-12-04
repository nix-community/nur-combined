{ lib, config, ... }:
let
  emId = 13924;
  sshPort = 32767;
  container = config.containers.emily;
in
{
  networking = {
    firewall.allowedTCPPorts = [ sshPort ];
    nat.forwardPorts = [
      {
        destination = container.localAddress;
        proto = "tcp";
        sourcePort = sshPort;
      }
    ];
  };

  users = {
    users.emily = {
      uid = emId;
      isNormalUser = true;
      expires = "2000-01-01";
      group = "emily";
    };
    groups.emily.gid = emId;
  };

  containers.emily = {
    privateNetwork = true;
    hostAddress = "192.168.100.20";
    localAddress = "192.168.100.21";

    autoStart = true;
    ephemeral = false;

    bindMounts."/emdata" = {
      hostPath = "/propdata/emily-files";
      isReadOnly = false;
    };

    config =
      { ... }:
      {
        system.stateVersion = "24.05";

        services.openssh = {
          enable = true;
          ports = [ sshPort ];
          openFirewall = true;
        };

        users = {
          users.emily = {
            uid = emId;
            isNormalUser = true;
            isSystemUser = false;
            hashedPassword = "$y$j9T$gP2phgJ9iSH.tWROn/T2C1$dwifP4R4SY4Fyd6W4vZ7tMDFhZB7Cfji9QvporeKUXB";
            group = "emily";
          };
          groups.emily.gid = emId;
          mutableUsers = false;
          allowNoPasswordLogin = true;
        };
      };
  };
}
