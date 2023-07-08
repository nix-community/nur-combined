# example configs:
# - <https://github.com/kittywitch/nixfiles/blob/main/services/prosody.nix>
# create users with:
# - `sudo -u prosody prosodyctl adduser colin@uninsane.org`

{ lib, ... }:

# XXX disabled: doesn't send messages to nixnet.social (only receives them).
# nixnet runs ejabberd, so revisiting that.
lib.mkIf false
{
  sane.persist.sys.plaintext = [
    { user = "prosody"; group = "prosody"; path = "/var/lib/prosody"; }
  ];
  sane.ports.ports."5222" = {
    protocol = [ "tcp" ];
    visibleTo.lan = true;
    visibleTo.wan = true;
    description = "colin-xmpp-client-to-server";
  };
  sane.ports.ports."5269" = {
    protocol = [ "tcp" ];
    visibleTo.wan = true;
    description = "colin-xmpp-server-to-server";
  };
  sane.ports.ports."5280" = {
    protocol = [ "tcp" ];
    visibleTo.lan = true;
    visibleTo.wan = true;
    description = "colin-xmpp-bosh";
  };
  sane.ports.ports."5281" = {
    protocol = [ "tcp" ];
    visibleTo.lan = true;
    visibleTo.wan = true;
    description = "colin-xmpp-prosody-https";  # necessary?
  };

  # provide access to certs
  users.users.prosody.extraGroups = [ "nginx" ];

  security.acme.certs."uninsane.org".extraDomainNames = [
    "conference.xmpp.uninsane.org"
    "upload.xmpp.uninsane.org"
  ];

  services.prosody = {
    enable = true;
    admins = [ "colin@uninsane.org" ];
    # allowRegistration = false;
    # extraConfig = ''
    #   s2s_require_encryption = true
    #   c2s_require_encryption = true
    # '';

    extraModules = [ "private" "vcard" "privacy" "compression" "component" "muc" "pep" "adhoc" "lastactivity" "admin_adhoc" "blocklist"];

    ssl.cert = "/var/lib/acme/uninsane.org/fullchain.pem";
    ssl.key = "/var/lib/acme/uninsane.org/key.pem";

    muc = [
      {
        domain = "conference.xmpp.uninsane.org";
      }
    ];
    uploadHttp.domain = "upload.xmpp.uninsane.org";

    virtualHosts = {
      localhost = {
        domain = "localhost";
        enabled = true;
      };
      "xmpp.uninsane.org" = {
        domain = "uninsane.org";
        enabled = true;
        ssl.cert = "/var/lib/acme/uninsane.org/fullchain.pem";
        ssl.key = "/var/lib/acme/uninsane.org/key.pem";
      }; 
    };
  };
}
