{ lib, ... }:

{

  virtualisation.containerd = {
    enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
      };
    };
  };

  networking.firewall.trustedInterfaces = lib.mkAfter [ "docker0" ];

  users.users.user = {
    extraGroups = [ "docker" ];
  };

}
