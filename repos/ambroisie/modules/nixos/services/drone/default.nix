# A docker-based CI/CD system
#
# Inspired by [1]
# [1]: https://github.com/Mic92/dotfiles/blob/master/nixos/eve/modules/drone.nix
{ lib, ... }:
{
  imports = [
    ./runner-docker
    ./runner-exec
    ./server
  ];

  options.my.services.drone = with lib; {
    enable = mkEnableOption "Drone CI";
    runners = mkOption {
      type = with types; listOf (enum [ "exec" "docker" ]);
      default = [ ];
      example = [ "exec" "docker" ];
      description = "Types of runners to enable";
    };
    admin = mkOption {
      type = types.str;
      default = "ambroisie";
      example = "admin";
      description = "Name of the admin user";
    };
    port = mkOption {
      type = types.port;
      default = 3030;
      example = 8080;
      description = "Internal port of the Drone UI";
    };
    secretFile = mkOption {
      type = types.str;
      example = "/run/secrets/drone-gitea.env";
      description = "Secrets to inject into Drone server";
    };
    sharedSecretFile = mkOption {
      type = types.str;
      example = "/run/secrets/drone-rpc.env";
      description = "Shared RPC secret to inject into server and runners";
    };
  };
}
