{
  flake.modules.nixos.fail2ban = {
    services.fail2ban = {
      enable = true;
      maxretry = 5;
      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/16"
        "172.16.0.0/12"
        "fdcc::/64"
        "192.168.0.0/16"
      ];
      bantime = "24h";
      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "504h";
        overalljails = true;
      };
    };
  };
}
