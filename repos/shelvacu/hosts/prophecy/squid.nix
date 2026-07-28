{ config, ... }:
let
  user = config.users.users.squid.name;
  group = config.users.groups.squid.name;
  port = 24280;
in
{
  config.services.squid = {
    enable = true;

    # I *think* these have no effect, but just in case
    proxyAddress = "127.0.0.1";
    proxyPort = port;

    configText = ''
      acl localnet src 10.0.0.0/8     # RFC 1918 possible internal network
      acl localnet src 172.16.0.0/12  # RFC 1918 possible internal network
      acl localnet src 192.168.0.0/16 # RFC 1918 possible internal network
      acl localnet src 169.254.0.0/16 # RFC 3927 link-local (directly plugged) machines
      acl localnet src fc00::/7       # RFC 4193 local private network range
      acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines

      acl SSL_ports port 443          # https

      acl Safe_ports port 80          # http
      acl Safe_ports port 21          # ftp
      acl Safe_ports port 443         # https
      acl Safe_ports port 70          # gopher
      acl Safe_ports port 210         # wais
      acl Safe_ports port 1025-65535  # unregistered ports
      acl Safe_ports port 280         # http-mgmt
      acl Safe_ports port 488         # gss-http
      acl Safe_ports port 591         # filemaker
      acl Safe_ports port 777         # multiling http

      acl CONNECT method CONNECT

      http_access deny !Safe_ports
      http_access deny CONNECT !SSL_ports
      http_access deny manager
      http_access deny to_localhost
      http_access allow localhost
      http_access deny all

      cache_log       stdio:/var/log/squid/cache.log
      access_log      stdio:/var/log/squid/access.log
      cache_store_log stdio:/var/log/squid/store.log

      pid_filename /run/squid.pid

      cache_effective_user ${user} ${group}

      http_port 127.0.0.1:${toString port}

      coredump_dir /var/cache/squid
    '';
  };
}
