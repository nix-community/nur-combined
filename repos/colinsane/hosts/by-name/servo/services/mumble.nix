# murmur is the server component of mumble.
# - docs: <https://www.mumble.info/documentation/>
# - config docs: <https://www.mumble.info/documentation/administration/config-file/>
#
# default port is 64738 (UDP and TCP)
#
# FIRST-RUN:
# - login from mumble client as `SuperUser`, password taken from `journalctl -u murmur`.
# - login from another machine and right click on self -> 'Register'
# - as SuperUser, right click on server root -> edit
#   - Groups tab: select "admin", then add the other registered user to the group.
# - log out as SuperUser and manage the server using that other user now.
#
# USAGE:
# - 'auth' group = any user who has registered a cert with the server.
{ ... }:
{
  sane.persist.sys.byStore.private = [
    { user = "murmur"; group = "murmur"; mode = "0700"; path = "/var/lib/murmur"; method = "bind"; }
  ];

  services.murmur.enable = true;
  services.murmur.welcometext = "welcome to Colin's mumble voice chat server";
  # max bandwidth (bps) **per user**. i believe this affects both voice and uploads?
  # mumble defaults to 558000, but nixos service defaults to 72000.
  services.murmur.bandwidth = 558000;
  services.murmur.imgMsgLength = 8 * 1024 * 1024;

  services.murmur.sslCert = "/var/lib/acme/mumble.uninsane.org/fullchain.pem";
  services.murmur.sslKey = "/var/lib/acme/mumble.uninsane.org/key.pem";
  services.murmur.sslCa = "/etc/ssl/certs/ca-bundle.crt";

  # allow clients on the LAN to discover this server
  services.murmur.bonjour = true;

  # mumble has a public server listing.
  # my server doesn't associate with that registry (unless i specify registerPassword).
  # however these settings appear to affect how the server presents itself to clients, regardless of registration.
  services.murmur.registerName = "mumble.uninsane.org";
  services.murmur.registerUrl = "https://mumble.uninsane.org";
  services.murmur.registerHostname = "mumble.uninsane.org";

  # defaultchannel=ID makes it so that unauthenticated users are placed in some specific channel when they join
  services.murmur.extraConfig = ''
    defaultchannel=2
  '';

  users.users.murmur.extraGroups = [
    "nginx"  # provide access to certs
  ];
  services.nginx.virtualHosts."mumble.uninsane.org" = {
    # allow ACME to procure a cert via nginx for this domain
    enableACME = true;
  };

  sane.dns.zones."uninsane.org".inet = {
    CNAME."mumble" = "native";
  };

  sane.ports.ports."64738" = {
    protocol = [ "tcp" "udp" ];
    visibleTo.lan = true;
    visibleTo.doof = true;
    description = "colin-mumble";
  };
}
