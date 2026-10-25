{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homelab.services = {
    enable = lib.mkEnableOption "Services for the homelab";
  };

  config = lib.mkIf config.homelab.services.enable {
    # Template unit: any service can opt in by setting
    #   serviceConfig.OnFailure = "notify-failure@%n.service"
    # %i = instance name (the failing service), %H = hostname — both
    # expanded by systemd before exec, passed as $1 and $2 to the script.
    systemd.services."notify-failure@" =
      lib.mkIf (config.homelab.notifications.ntfySecretsFile != null)
        {
          description = "Send ntfy alert for failed service %i";
          serviceConfig = {
            Type = "oneshot";
            # Secrets file must contain: NTFY_TOPIC=https://ntfy.example.com/topic
            EnvironmentFile = config.homelab.notifications.ntfySecretsFile;
            ExecStart =
              pkgs.writeShellScript "notify-failure" ''
                ${pkgs.curl}/bin/curl -sS -X POST "$NTFY_TOPIC" \
                  -H "Title: ❌ $1 failed on $2" \
                  -H "Priority: urgent" \
                  -H "Tags: sos,warning" \
                  -d "Service $1 has failed. Run: journalctl -u $1 -n 50"
              ''
              + " %i %H";
          };
        };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    security.acme = {
      acceptTerms = true;
      defaults.email = "${config.homelab.email}";
      certs.${config.homelab.baseDomainName} = {
        reloadServices = [ "caddy.service" ];
        domain = "${config.homelab.baseDomainName}";
        extraDomainNames = [ "*.${config.homelab.baseDomainName}" ];
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        group = config.services.caddy.group;
        environmentFile = config.homelab.cloudflare.dnsCredentialsFile;
      };
    };
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/cloudflare@v0.2.2"
          "github.com/mholt/caddy-ratelimit@v0.1.0"
        ];
        hash = "sha256-hBi7HDQHmEUJIUrU9h32ctPTrg/mOiDrh49YHyN7OE8=";
      };
      globalConfig = ''
        auto_https off
      '';
      virtualHosts = {
        "https://${config.homelab.baseDomainName}" = {
          extraConfig = ''
            redir https://{host}{uri}
          '';
        };
        "http://*.${config.homelab.baseDomainName}" = {
          extraConfig = ''
            redir https://{host}{uri}
          '';
        };
      };
    };
  };

  imports = [
    ./miniflux
    ./auth
    ./glance
    ./niks3
    ./cloudrun
    ./scrutiny
    ./restic
    ./isponsorblocktv
    ./lard
    ./calibre-web
    ./asterisk
    ./irc
    ./navidrome
    ./t3code
    ./slackbots/riddlebot.nix
  ];
}
