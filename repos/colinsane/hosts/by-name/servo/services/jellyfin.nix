# configuration options (today i don't store my config in nix):
#
# - jellyfin-web can be statically configured (result/share/jellyfin-web/config.json)
#   - <https://jellyfin.org/docs/general/clients/web-config>
#   - configure server list, plugins, "menuLinks", colors
#
# - jellfyin server is configured in /var/lib/jellfin/
#   - root/default/<LibraryType>/
#     - <LibraryName>.mblink: contains the directory name where this library lives
#     - options.xml: contains preferences which were defined in the web UI during import
#       - e.g. `EnablePhotos`, `EnableChapterImageExtraction`, etc.
#   - config/encoding.xml: transcoder settings
#   - config/system.xml: misc preferences like log file duration, audiobook resume settings, etc.
#   - data/jellyfin.db: maybe account definitions? internal state?

{ config, lib, ... }:

{
  # identical to:
  # services.jellyfin.openFirewall = true;
  networking.firewall.allowedUDPPorts = [
    # https://jellyfin.org/docs/general/networking/index.html
    1900  # UPnP service discovery
    7359  # Jellyfin-specific (?) client discovery
  ];
  networking.firewall.allowedTCPPorts = [
    8096  # HTTP (for the LAN)
    8920  # HTTPS (for the LAN)
  ];
  sane.persist.sys.plaintext = [
    { user = "jellyfin"; group = "jellyfin"; mode = "0700"; directory = "/var/lib/jellyfin"; }
  ];
  sane.fs."/var/lib/jellyfin/config/logging.json" = {
    # "Emby.Dlna" logging: <https://jellyfin.org/docs/general/networking/dlna>
    symlink.text = ''
      {
        "Serilog": {
          "MinimumLevel": {
            "Default": "Information",
            "Override": {
              "Microsoft": "Warning",
              "System": "Warning",
              "Emby.Dlna": "Debug",
              "Emby.Dlna.Eventing": "Debug"
            }
          },
          "WriteTo": [
            {
              "Name": "Console",
              "Args": {
                "outputTemplate": "[{Timestamp:HH:mm:ss}] [{Level:u3}] [{ThreadId}] {SourceContext}: {Message:lj}{NewLine}{Exception}"
              }
            }
          ],
          "Enrich": [ "FromLogContext", "WithThreadId" ]
        }
      }
    '';
    wantedBeforeBy = [ "jellyfin.service" ];
  };

  # Jellyfin multimedia server
  # this is mostly taken from the official jellfin.org docs
  services.nginx.virtualHosts."jelly.uninsane.org" = {
    addSSL = true;
    enableACME = true;
    # inherit kTLS;

    locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_set_header X-Forwarded-Host $http_host;

        # Disable buffering when the nginx proxy gets very resource heavy upon streaming
        proxy_buffering off;
      '';
    };
    # locations."/web/" = {
    #   proxyPass = "http://127.0.0.1:8096/web/index.html";
    #   extraConfig = ''
    #     proxy_set_header Host $host;
    #     proxy_set_header X-Real-IP $remote_addr;
    #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #     proxy_set_header X-Forwarded-Proto $scheme;
    #     proxy_set_header X-Forwarded-Protocol $scheme;
    #     proxy_set_header X-Forwarded-Host $http_host;
    #   '';
    # };
    locations."/socket" = {
      proxyPass = "http://127.0.0.1:8096";
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_set_header X-Forwarded-Host $http_host;
      '';
    };
  };

  sane.services.trust-dns.zones."uninsane.org".inet.CNAME."jelly" = "native";

  services.jellyfin.enable = true;
}
