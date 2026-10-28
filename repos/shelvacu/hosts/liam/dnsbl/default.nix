{ config, pkgs, ... }:
let
  # spamhaus/uribl/surbl refuse queries that come through public resolvers
  unboundPort = 5335;
  socketDir = "/run/dnsbl-milter";
  socket = "${socketDir}/milter.sock";
  milter = pkgs.writers.writePython3 "dnsbl-milter" {
    libraries = with pkgs.python3Packages; [
      pymilter
      dnspython
      publicsuffixlist
    ];
    flakeIgnore = [
      "E501"
      "E731"
    ];
  } (builtins.readFile ./milter.py);
in
{
  services.unbound = {
    enable = true;
    resolveLocalQueries = false;
    settings.server = {
      interface = [ "127.0.0.1@${toString unboundPort}" ];
      access-control = [ "127.0.0.0/8 allow" ];
      do-ip6 = false;
    };
  };

  users.users.dnsbl-milter = {
    isSystemUser = true;
    group = config.services.postfix.group;
  };

  systemd.services.dnsbl-milter = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "unbound.service" ];
    after = [ "unbound.service" ];
    serviceConfig = {
      ExecStart = "${milter} unix:${socket} 127.0.0.1 ${toString unboundPort}";
      User = "dnsbl-milter";
      Group = config.services.postfix.group;
      RuntimeDirectory = "dnsbl-milter";
      RuntimeDirectoryMode = "0750";
      UMask = "0007";
      Restart = "always";
    };
  };

  systemd.services.postfix = {
    wants = [ "dnsbl-milter.service" ];
    after = [ "dnsbl-milter.service" ];
  };

  services.postfix.settings.main.smtpd_milters = [ "{ unix:${socket}, default_action=accept }" ];
}
