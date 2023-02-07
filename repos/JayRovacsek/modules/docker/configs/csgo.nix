let csgoUserConfig = import ../../../users/service-accounts/csgo.nix;
in rec {
  image = "cm2network/csgo:latest";
  serviceName = "csgo";
  ports = [ "27015:27015/tcp" "27015:27015/udp" "27005:27005/udp" ];
  volumes = [ "/etc/csgo-data:/home/steam/csgo-dedicated/:rw" ];
  environment = {
    TZ = "Australia/Sydney";
    SRCDS_TOKEN = "changeme";
    SRCDS_RCONPW =
      "changeme"; # (value can be overwritten by csgo/cfg/server.cfg)
    SRCDS_PW = "changeme"; # (value can be overwritten by csgo/cfg/server.cfg)
    SRCDS_PORT = 27015;
    SRCDS_TV_PORT = 27020;
    SRCDS_NET_PUBLIC_ADDRESS =
      "0"; # (public facing ip, useful for local network setups)
    SRCDS_IP = "0"; # (local ip to bind)
    SRCDS_LAN = "0";
    SRCDS_FPSMAX = 300;
    SRCDS_TICKRATE = 128;
    SRCDS_MAXPLAYERS = 14;
    SRCDS_STARTMAP = "de_dust2";
    SRCDS_REGION = 3;
    SRCDS_MAPGROUP = "mg_active";
    SRCDS_GAMETYPE = 0;
    SRCDS_GAMEMODE = 1;
    SRCDS_HOSTNAME = "New CSGO Server";
    SRCDS_WORKSHOP_START_MAP = 0;
    SRCDS_HOST_WORKSHOP_COLLECTION = 0;
  };
  extraOptions = [
    "--name=${serviceName}"
    ''--user="${csgoUserConfig.name}/${csgoUserConfig.group.name}"''
    "--net=host"
  ];
}
