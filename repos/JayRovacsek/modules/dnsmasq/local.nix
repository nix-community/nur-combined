let user = import ../../users/service-accounts/dnsmasq.nix;
in {
  inherit (user) uid;
  inherit (user.group) gid;
  name = "dnsmasq.d/03-local.conf";
  text = ''
    # Local Address Binds
    address=/pfsense.lan/192.168.1.1
    address=/ubiquiti_ap.lan/192.168.1.3
    address=/dragonite.lan/192.168.1.220
    address=/alakazam.lan/192.168.1.221
    address=/speedtest.lan/192.168.1.222
    address=/duplicati.lan/192.168.1.223
    address=/tv.lan/192.168.3.2
    address=/wigglytuff.lan/192.168.6.6
    address=/car_bed.lan/192.168.3.10
    address=/jackett.lan/192.168.4.129
    address=/deluge.lan/192.168.4.130
    address=/sonarr.lan/192.168.4.131
    address=/radarr.lan/192.168.4.132
    address=/lidarr.lan/192.168.4.133
    address=/ombi.lan/192.168.4.134
    address=/tdarr.lan/192.168.4.135
    address=/tdarr-node-01.lan/192.168.4.136
    address=/prowlarr.lan/192.168.4.137
    address=/flare-solverr.lan/192.168.4.138
    address=/swag.lan/192.168.5.3
    address=/jellyfin.lan/192.168.5.4
    address=/pihole.lan/192.168.6.2
    address=/stubby.lan/192.168.6.3
    address=/jigglypuff.lan/192.168.6.4
    address=/authelia.lan/192.168.9.2
    address=/nextcloud.lan/192.168.10.2
    address=/home-assistant.lan/192.168.12.2
    address=/cache.lan/192.168.16.2
    address=/minecraft.lan/192.168.17.5
    address=/minecraft.rovacsek.com/192.168.17.5
    address=/valheim.lan/192.168.17.3
    address=/valheim.rovacsek.com/192.168.17.3
    address=/terraria.lan/192.168.17.4
    address=/terraria.rovacsek.com/192.168.17.4
    address=/.rovacsek.com/192.168.5.3
  '';
  mode = "0444";
}
