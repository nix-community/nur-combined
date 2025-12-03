# configuration options (today only a *subset* of the config is done in nix)
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
#
# N.B.: default install DOES NOT SUPPORT DLNA out of the box.
#       one must install it as a "plugin", which can be done through the UI.
{ config, lib, ... }:

# lib.mkIf false  #< XXX(2024-11-17): disabled because it hasn't been working for months; web UI hangs on load, TVs see no files
{
  config = lib.mkIf (config.sane.maxBuildCost >= 2) {
    # https://jellyfin.org/docs/general/networking/index.html
    sane.ports.ports."1900" = {
      protocol = [ "udp" ];
      visibleTo.lan = true;
      description = "colin-upnp-for-jellyfin";
    };
    sane.ports.ports."7359" = {
      protocol = [ "udp" ];
      visibleTo.lan = true;
      description = "colin-jellyfin-specific-client-discovery";
      # ^ not sure if this is necessary: copied this port from nixos jellyfin.openFirewall
    };
    # not sure if 8096/8920 get used either:
    sane.ports.ports."8096" = {
      protocol = [ "tcp" ];
      visibleTo.lan = true;
      description = "colin-jellyfin-http-lan";
    };
    sane.ports.ports."8920" = {
      protocol = [ "tcp" ];
      visibleTo.lan = true;
      description = "colin-jellyfin-https-lan";
    };

    sane.persist.sys.byStore.plaintext = [
      { user = "jellyfin"; group = "jellyfin"; mode = "0700"; path = "/var/lib/jellyfin/data"; method = "bind"; }
      { user = "jellyfin"; group = "jellyfin"; mode = "0700"; path = "/var/lib/jellyfin/metadata"; method = "bind"; }
      # TODO: ship plugins statically, via nix. that'll be less fragile
      { user = "jellyfin"; group = "jellyfin"; mode = "0700"; path = "/var/lib/jellyfin/plugins/DLNA_5.0.0.0"; method = "bind"; }
      { user = "jellyfin"; group = "jellyfin"; mode = "0700"; path = "/var/lib/jellyfin/root"; method = "bind"; }
    ];
    sane.persist.sys.byStore.ephemeral = [
      { user = "jellyfin"; group = "jellyfin"; mode = "0700"; path = "/var/lib/jellyfin/log"; method = "bind"; }
      { user = "jellyfin"; group = "jellyfin"; mode = "0700"; path = "/var/lib/jellyfin/transcodes"; method = "bind"; }
    ];

    services.jellyfin.enable = true;
    users.users.jellyfin.extraGroups = [ "media" ];

    sane.fs."/var/lib/jellyfin".dir.acl = {
      user = "jellyfin";
      group = "jellyfin";
      mode = "0700";
    };

    # `"Jellyfin.Plugin.Dlna": "Debug"` logging: <https://jellyfin.org/docs/general/networking/dlna>
    # TODO: switch Dlna back to 'Information' once satisfied with stability
    sane.fs."/var/lib/jellyfin/config/logging.json".symlink.text = ''
      {
        "Serilog": {
          "MinimumLevel": {
            "Default": "Information",
            "Override": {
              "Microsoft": "Warning",
              "System": "Warning",
              "Jellyfin.Plugin.Dlna": "Debug"
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

    sane.fs."/var/lib/jellyfin/config/network.xml".file.text = ''
      <?xml version="1.0" encoding="utf-8"?>
      <NetworkConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <BaseUrl />
        <EnableHttps>false</EnableHttps>
        <RequireHttps>false</RequireHttps>
        <InternalHttpPort>8096</InternalHttpPort>
        <InternalHttpsPort>8920</InternalHttpsPort>
        <PublicHttpPort>8096</PublicHttpPort>
        <PublicHttpsPort>8920</PublicHttpsPort>
        <AutoDiscovery>true</AutoDiscovery>
        <EnableUPnP>false</EnableUPnP>
        <EnableIPv4>true</EnableIPv4>
        <EnableIPv6>false</EnableIPv6>
        <EnableRemoteAccess>true</EnableRemoteAccess>
        <LocalNetworkSubnets>
          <string>10.78.76.0/22</string>
        </LocalNetworkSubnets>
        <KnownProxies>
          <string>127.0.0.1</string>
          <string>localhost</string>
          <string>10.78.79.1</string>
        </KnownProxies>
        <IgnoreVirtualInterfaces>false</IgnoreVirtualInterfaces>
        <VirtualInterfaceNames />
        <EnablePublishedServerUriByRequest>false</EnablePublishedServerUriByRequest>
        <PublishedServerUriBySubnet />
        <RemoteIPFilter />
        <IsRemoteIPFilterBlacklist>false</IsRemoteIPFilterBlacklist>
      </NetworkConfiguration>
    '';

    # guest user id is `5ad194d60dca41de84b332950ffc4308`
    sane.fs."/var/lib/jellyfin/plugins/configurations/Jellyfin.Plugin.Dlna.xml".file.text = ''
      <?xml version="1.0" encoding="utf-8"?>
      <DlnaPluginConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <EnablePlayTo>true</EnablePlayTo>
        <ClientDiscoveryIntervalSeconds>60</ClientDiscoveryIntervalSeconds>
        <BlastAliveMessages>true</BlastAliveMessages>
        <AliveMessageIntervalSeconds>180</AliveMessageIntervalSeconds>
        <SendOnlyMatchedHost>true</SendOnlyMatchedHost>
        <DefaultUserId>5ad194d6-0dca-41de-84b3-32950ffc4308</DefaultUserId>
      </DlnaPluginConfiguration>
    '';

    # fix LG TV to play more files.
    # there are certain files for which it only supports Direct Play (not even "Direct Stream" -- but "Direct Play").
    # this isn't a 100% fix: patching the profile allows e.g. Azumanga Daioh to play,
    # but A Place Further Than the Universe still fails as before.
    #
    # profile is based on upstream: <https://github.com/jellyfin/jellyfin-plugin-dlna>
    sane.fs."/var/lib/jellyfin/plugins/DLNA_5.0.0.0/profiles/LG Smart TV.xml".symlink.target = ./dlna/user/LG_Smart_TV.xml;
    # XXX(2024-11-17): old method, but the file referenced seems not to be used and setting just it causes failures:
    # > [DBG] Jellyfin.Plugin.Dlna.ContentDirectory.ContentDirectoryService: Not eligible for DirectPlay due to unsupported subtitles
    # sane.fs."/var/lib/jellyfin/plugins/configurations/dlna/user/LG Smart TV.xml".symlink.target = ./dlna/user/LG_Smart_TV.xml;

    systemd.services.jellyfin.unitConfig.RequiresMountsFor = [
      "/var/media"
    ];

    # Jellyfin multimedia server
    # this is mostly taken from the official jellfin.org docs
    services.nginx.virtualHosts."jelly.uninsane.org" = {
      forceSSL = true;
      enableACME = true;
      # inherit kTLS;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        # extraConfig = ''
        #   # Disable buffering when the nginx proxy gets very resource heavy upon streaming
        #   proxy_buffering off;
        # '';
      };
    };

    sane.dns.zones."uninsane.org".inet.CNAME."jelly" = "native";
  };
}
