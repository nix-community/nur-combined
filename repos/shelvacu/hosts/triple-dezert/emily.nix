{ config, ... }:
let
  sshPort = 32767;
  container = config.containers.emily;
in
{
  networking.firewall.allowedTCPPorts = [ sshPort ];
  networking.nat.forwardPorts = [
    {
      destination = container.localAddress;
      proto = "tcp";
      sourcePort = sshPort;
    }
  ];

  containers.emily = {
    privateNetwork = true;
    hostAddress = "192.168.100.20";
    localAddress = "192.168.100.21";

    autoStart = false;
    ephemeral = false;

    bindMounts."/emdata" = {
      hostPath = "/trip/ncdata/data/melamona/files";
      isReadOnly = false;
    };

    config =
      { ... }:
      {
        system.stateVersion = "24.05";

        services.openssh.enable = true;
        services.openssh.ports = [ sshPort ];
        services.openssh.openFirewall = true;

        # systemd.tmpfiles.settings."asdf"."/emdata"."Z" = ...;

        users.groups.emily.gid = 999;
        users.users.emily = {
          isNormalUser = true;
          isSystemUser = false;
          hashedPassword = "$y$j9T$gP2phgJ9iSH.tWROn/T2C1$dwifP4R4SY4Fyd6W4vZ7tMDFhZB7Cfji9QvporeKUXB";
          group = "emily";
        };
        users.mutableUsers = false;
        users.allowNoPasswordLogin = true;
      };
  };
}
