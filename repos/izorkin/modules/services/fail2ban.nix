{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.fail2ban-custom;

  fail2banConf = pkgs.writeText "fail2ban.conf" cfg.daemonConfig;

  jailConf = pkgs.writeText "jail.conf"
    (concatStringsSep "\n" (attrValues (flip mapAttrs cfg.jails (name: def:
      optionalString (def != "")
        ''
          [${name}]
          ${def}
        ''))));

in

{

  ###### interface

  options = {

    services.fail2ban = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Whether to enable the fail2ban service.";
      };

      package = mkOption {
        default = pkgs.fail2ban;
        type = types.package;
      };

      ignoreip = mkOption {
        type = types.lines;
        default = ''
          127.0.0.0/8
        '';
      };

      sender = mkOption {
        type = types.str;
        default = "root@${config.networking.hostName}";
      };

      protocol = mkOption {
        type = types.str;
        default = "tcp";
      };

      chain = mkOption {
        type = types.str;
        default = "INPUT";
      };

      banaction = mkOption {
        type = types.str;
        default = "iptables-multiport";
      };

      actions = mkOption {
        type = types.str;
        default = "%(action_)s";
      };

      blocklist_apikey = mkOption {
        type = types.str;
        default = "";
      };

      ban-time-incr-enable = mkOption {
        type = types.str;
        default = "false";
      };

      ban-time-incr = mkOption {
        type = types.lines;
        default = ''
          bantime.rndtime      =
          bantime.maxtime      =
          bantime.factor       = 1
          bantime.formula      = ban.Time * (1<<(ban.Count if ban.Count<20 else 20)) * banFactor
          bantime.formula      = ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)
          bantime.multipliers  = 1 2 4 8 16 32 64
          bantime.multipliers  = 1 5 30 60 300 720 1440 2880
          bantime.overalljails = false
        '';
      };

      daemonConfig = mkOption {
        default = ''
          [Definition]
          loglevel     = INFO
          logtarget    = SYSLOG
          syslogsocket = auto
          socket       = /run/fail2ban/fail2ban.sock
          pidfile      = /run/fail2ban/fail2ban.pid
          dbfile       = /var/lib/fail2ban/fail2ban.sqlite3
          dbpurgeage   = 86400 
        '';
        type = types.lines;
        description = ''
          The contents of Fail2ban's main configuration file.  It's
          generally not necessary to change it.
        '';
      };

      jails = mkOption {
        default = { };
        example = literalExample ''
          { apache-nohome-iptables = '''
              # Block an IP address if it accesses a non-existent
              # home directory more than 5 times in 10 minutes,
              # since that indicates that it's scanning.
              filter   = apache-nohome
              action   = iptables-multiport[name=HTTP, port="http,https"]
              logpath  = /var/log/httpd/error_log*
              findtime = 600
              bantime  = 600
              maxretry = 5
            ''';
          }
        '';
        type = types.attrsOf types.lines;
        description = ''
          The configuration of each Fail2ban “jail”.  A jail
          consists of an action (such as blocking a port using
          <command>iptables</command>) that is triggered when a
          filter applied to a log file triggers more than a certain
          number of times in a certain time period.  Actions are
          defined in <filename>/etc/fail2ban/action.d</filename>,
          while filters are defined in
          <filename>/etc/fail2ban/filter.d</filename>.
        '';
      };
    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    environment.etc."fail2ban/fail2ban.conf".source = fail2banConf;
    environment.etc."fail2ban/jail.conf".source = jailConf;
    environment.etc."fail2ban/action.d".source = "${cfg.package}/etc/fail2ban/action.d/*.conf";
    environment.etc."fail2ban/filter.d".source = "${cfg.package}/etc/fail2ban/filter.d/*.conf";

    systemd.services.fail2ban =
      { description = "Fail2ban Intrusion Prevention System";

        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        partOf = optional config.networking.firewall.enable "firewall.service";

        restartTriggers = [ fail2banConf jailConf ];
        path = [ cfg.package pkgs.iptables pkgs.iproute ];

        preStart = ''
          mkdir -p /var/lib/fail2ban
        '';

        unitConfig.Documentation = "man:fail2ban(1)";

        serviceConfig = {
          Type = "forking";
          ExecStart = "${cfg.package}/bin/fail2ban-client -x start";
          ExecStop = "${cfg.package}/bin/fail2ban-client stop";
          ExecReload = "${cfg.package}/bin/fail2ban-client reload";
          PIDFile = "/run/fail2ban/fail2ban.pid";
          Restart = "always";

          ReadOnlyDirectories = "/";
          ReadWriteDirectories = "/run/fail2ban /var/tmp /var/lib";
          PrivateTmp = "true";
          RuntimeDirectory = "fail2ban";
          CapabilityBoundingSet = "CAP_DAC_READ_SEARCH CAP_NET_ADMIN CAP_NET_RAW";
        };
      };

    # Add some reasonable default jails.  The special "DEFAULT" jail
    # sets default values for all other jails.
    services.fail2ban-custom.jails.DEFAULT = ''
      bantime.increment    = ${cfg.ban-time-incr-enable}
      ${cfg.ban-time-incr}
      ignoreip             = ${cfg.ignoreip}
      bantime              = 600
      findtime             = 600
      maxretry             = 5
      backend              = systemd
      usedns               = no
      logencoding          = auto
      enabled              = true
      filter               = %(__name__)s

      destemail            = root@localhost
      sender               = ${cfg.sender}
      mta                  = ${pkgs.ssmtp}/bin/sendmail
      protocol             = ${cfg.protocol}
      port                 = 0:65535
      fail2ban_agent       = Fail2Ban/%(fail2ban_version)s
      chain                = ${cfg.chain}
      banaction            = ${cfg.banaction}
      action_              = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
      action_mw            = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
                             %(mta)s-whois[name=%(__name__)s, sender="%(sender)s", dest="%(destemail)s", protocol="%(protocol)s", chain="%(chain)s"]
      action_mwl           = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
                             %(mta)s-whois-lines[name=%(__name__)s, sender="%(sender)s", dest="%(destemail)s", logpath=%(logpath)s, chain="%(chain)s"]
      action_xarf          = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
                             xarf-login-attack[service=%(__name__)s, sender="%(sender)s", logpath=%(logpath)s, port="%(port)s"]
      action_cf_mwl        = cloudflare[cfuser="%(cfemail)s", cftoken="%(cfapikey)s"]
                             %(mta)s-whois-lines[name=%(__name__)s, sender="%(sender)s", dest="%(destemail)s", logpath=%(logpath)s, chain="%(chain)s"]
      blocklist_de_apikey  = ${cfg.blocklist_apikey}
      action_blocklist_de  = blocklist_de[email="%(sender)s", service=%(filter)s, apikey="%(blocklist_de_apikey)s", agent="%(fail2ban_agent)s"]
      action_badips        = badips.py[category="%(__name__)s", banaction="%(banaction)s", agent="%(fail2ban_agent)s"]
      action_badips_report = badips[category="%(__name__)s", agent="%(fail2ban_agent)s"]
      action_abuseipdb     = abuseipdb
      action               = ${cfg.actions}
    '';

    # Block SSH if there are too many failing connection attempts.
    services.fail2ban.jails.ssh-iptables = ''
      filter               = sshd
      port                 = "${concatMapStringsSep "," (p: toString p) config.services.openssh.ports}"
      maxretry             = 5
    '';
  };
}
