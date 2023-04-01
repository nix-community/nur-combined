{ lib, ... }:
{
  imports = [
    ./agent-docker
    ./agent-exec
    ./server
  ];

  options.my.services.woodpecker = with lib; {
    enable = mkEnableOption "Woodpecker CI";
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
      description = "Internal port of the Woodpecker UI";
    };
    rpcPort = mkOption {
      type = types.port;
      default = 3031;
      example = 8080;
      description = "Internal port of the Woodpecker UI";
    };
    secretFile = mkOption {
      type = types.str;
      example = "/run/secrets/woodpecker.env";
      description = "Secrets to inject into Woodpecker server";
    };
    sharedSecretFile = mkOption {
      type = types.str;
      example = "/run/secrets/woodpecker.env";
      description = "Shared RPC secret to inject into server and runners";
    };
  };
}
