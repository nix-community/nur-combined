let
  piholeUserConfig = import ../../../users/service-accounts/pihole.nix;
  piholeUid = builtins.toString piholeUserConfig.uid;
  piholeGid = builtins.toString piholeUserConfig.group.gid;
in rec {
  autoStart = true;
  image = "pihole/pihole:latest";
  serviceName = "pihole";
  ports = [ "53:53/tcp" "53:53/udp" "80:80/tcp" ];
  volumes =
    [ "/etc/pihole:/etc/pihole:rw" "/etc/pihole/dnsmasq.d:/etc/dnsmasq.d:rw" ];
  environment = {
    TZ = "Australia/Sydney";
    PIHOLE_DNS_ = "127.0.0.1#8053";
    DNS_BOGUS_PRIV = "true";
    DNS_FQDN_REQUIRED = "true";
    DHCP_ACTIVE = "false";
    DNSMASQ_LISTENING = "all";
    DNSMASQ_USER = "pihole";
    IPv6 = "false";
    WEBPASSWORD = "password";
    WEBTHEME = "default-dark";
    CUSTOM_CACHE_SIZE = "10000";
    FTL_CMD = "no-daemon -- --dns-forward-max 500";
    FTLCONF_RESOLVE_IPV6 = "no";
    FTLCONF_SOCKET_LISTENING = "all";
    FTLCONF_NAMES_FROM_NETDB = "true";
    FTLCONF_REPLY_WHEN_BUSY = "DROP";
    FTLCONF_SHOW_DNSSEC = "true";
    FTLCONF_RATE_LIMIT = "0/0";
    PIHOLE_UID = piholeUid;
    PIHOLE_GID = piholeGid;
  };
  extraOptions = [
    "--name=${serviceName}"
    "--cap-add=CAP_NET_BIND_SERVICE"
    "--cap-add=CAP_SYS_NICE"
    "--cap-add=CAP_CHOWN"
    "--network=host"
  ];
}
