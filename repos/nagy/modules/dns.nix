{
  networking.hosts = {
    # https://developers.google.com/speed/public-dns
    "8.8.8.8" = [ "dns.google" ];
    "8.8.4.4" = [ "dns.google" ];

    # https://developers.cloudflare.com/1.1.1.1/encryption/dns-over-tls/
    "1.1.1.1" = [
      "1dot1dot1dot1.cloudflare-dns.com"
      "one.one.one.one"
    ];
    "1.0.0.1" = [
      "1dot1dot1dot1.cloudflare-dns.com"
      "one.one.one.one"
    ];

    "9.9.9.9" = [ "dns9.quad9.net" ];

    # https://mullvad.net/de/help/dns-over-https-and-dns-over-tls
    "194.242.2.2" = [ "dns.mullvad.net" ];
    "194.242.2.3" = [ "adblock.dns.mullvad.net" ];
    "194.242.2.4" = [ "base.dns.mullvad.net" ];
    "194.242.2.5" = [ "extended.dns.mullvad.net" ];
    "194.242.2.6" = [ "family.dns.mullvad.net" ];
    "194.242.2.9" = [ "all.dns.mullvad.net" ];

    # https://en.wikipedia.org/wiki/Archive.today#Cloudflare_DNS_availability
    "23.137.248.133" = [
      "archive.fo"
      "archive.is"
      "archive.li"
      "archive.md"
      "archive.ph"
      "archive.today"
      "archive.vn"
    ];

    # openNIC project
    # https://servers.opennic.org/
    # tier 2
    "185.84.81.194" = [ "ns1.de.dns.opennic.glue" ];
    "162.243.19.47" = [ "ns1.ny.us.dns.opennic.glue" ];
    "63.231.92.27" = [ "ns1.co.us.dns.opennic.glue" ];
    "94.247.43.254" = [ "opennic1.eth-services.de" ];
    # tier 1
    # "161.97.219.84" = [ "ns2.opennic.glue" ];
    # "207.192.71.13" = [ "ns6.opennic.glue" ];
  };
}
