{ config, ... }:
let
  userId = 13925;
  sshPort = 26101;
  container = config.containers.java;
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
    users.java = {
      uid = userId;
      isNormalUser = true;
      expires = "2000-01-01";
      group = "java";
    };
    groups.java.gid = userId;
  };

  containers.java = {
    privateNetwork = true;
    hostAddress = "192.168.100.30";
    localAddress = "192.168.100.31";

    autoStart = true;
    ephemeral = false;

    bindMounts."/data" = {
      hostPath = "/propdata/java-files";
      isReadOnly = false;
    };

    bindMounts."/recovered" = {
      hostPath = "/propdata/vm-bigdata/savm/recovered";
      isReadOnly = true;
    };

    config = { ... }: {
      system.stateVersion = "26.11";

      services.openssh = {
        enable = true;
        ports = [ sshPort ];
        openFirewall = true;
      };

      users = {
        users.java = {
          uid = userId;
          isNormalUser = true;
          isSystemUser = false;
          group = "java";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICq8ju6Hc+YoVJnr7+zN0ne2ydYQHkoDKCJE9K8aYRrX java@ghost" #javi framework laptop
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPI8z4PxR0H1riEhLwyBSfrbtb6mvTEhrEZkb5W+AJRd root@nixos" # homelab live ssh keys
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7l2+gcoeZ3rcuFoodlkfkW6++cmVwr5IRFMeD6H9r javi@homelab-nixos-btw"
          ];
        };
        groups.java.gid = userId;
        mutableUsers = false;
        allowNoPasswordLogin = true;
      };
    };
  };
}
