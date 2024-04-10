{ pkgs, ... }:
{

  enable = true;
  eula = true;
  openFirewall = true;
  dataDir = "/var/lib/minecraft";
  # environmentFile=;
  servers = {
    pure = {
      enable = true;
      autoStart = true;
      openFirewall = true;
      package = pkgs.quilt-server;
      # whitelist = {
      #   user1 = "";
      # };
      serverProperties = {
        server-port = 43000;
        difficulty = 1;
        gamemode = 1;
        online-mode = false;
        max-players = 5;
        motd = "nya";
        white-list = false;
        enable-rcon = true;
        "rcon.port" = 25575;
        "rcon.password" = "123?";
      };
    };
  };
}
