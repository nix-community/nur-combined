{ config, pkgs, ... }:
{
  # FABRIC + MINECRAFT
  systemd.services.fabric-minecraft-server = {
      description = "Fabric+Minecraft Server Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      restartTriggers = [ /home/mar ];

      serviceConfig = {
          ExecStart = "${pkgs.jre}/bin/java -jar server.jar";
          Restart = "always";
          WorkingDirectory = "/home/mar";
      };
  };

  services.vsftpd = {
      enable = true;
      writeEnable = true;
      localUsers = true;
      extraConfig = ''
        pasv_min_port=56250
        pasv_max_port=56260
      '';
  };

  networking.firewall.allowedTCPPorts = [ 20 21 25565 ];
  networking.firewall.allowedTCPPortRanges = [{from = 56250; to = 56260;}];

  # TASKSERVER
  services.taskserver = {
      enable = true;
      fqdn = "samhatfield.me";
      listenHost = "::";
      organisations.personal.users = [ "sam" ];
  };
}
