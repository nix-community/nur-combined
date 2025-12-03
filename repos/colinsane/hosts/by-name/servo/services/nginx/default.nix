# docs: <https://nixos.wiki/wiki/Nginx>
# docs: <https://nginx.org/en/docs/>
{ lib, pkgs, ... }:
{
  imports = [
    ./uninsane.org.nix
    ./waka.laka.osaka
  ];

  sane.ports.ports."80" = {
    protocol = [ "tcp" ];
    visibleTo.lan = true;
    visibleTo.ovpns = true;  # so that letsencrypt can procure a cert for the mx record
    visibleTo.doof = true;
    description = "colin-http-uninsane.org";
  };
  sane.ports.ports."443" = {
    protocol = [ "tcp" ];
    visibleTo.lan = true;
    visibleTo.doof = true;
    description = "colin-https-uninsane.org";
  };

  services.nginx.enable = true;

  users.users.nginx.extraGroups = [ "anubis" ];
  # nginxStable is one release behind nginxMainline.
  # nginx itself recommends running mainline; nixos defaults to stable.
  # services.nginx.package = pkgs.nginxMainline;
  # XXX(2024-07-31): nixos defaults to zlib-ng -- supposedly more performant, but spams log with
  # "gzip filter failed to use preallocated memory: ..."
  # XXX(2025-07-24): "gzip filter" spam is gone => use default nginx package
  # services.nginx.package = pkgs.nginxMainline.override { zlib = pkgs.zlib; };
  services.nginx.appendConfig = ''
    # use 1 process per core.
    # may want to increase worker_connections too, but `ulimit -n` must be increased first.
    worker_processes auto;
  '';

  # this is the standard `combined` log format, with the addition of $host
  # so that we have the virtualHost in the log.
  # KEEP IN SYNC WITH GOACCESS
  # goaccess calls this VCOMBINED:
  # - <https://gist.github.com/jyap808/10570005>
  services.nginx.commonHttpConfig = ''
    log_format vcombined '$host:$server_port $remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referrer" "$http_user_agent"';
    access_log /var/log/nginx/private.log vcombined;
  '';
  # enables gzip and sets gzip_comp_level = 5
  services.nginx.recommendedGzipSettings = true;
  # enables zstd and sets zstd_comp_level = 9
  # services.nginx.recommendedZstdSettings = true;  #< XXX(2025-07-18): nginx zstd integration is unmaintained in NixOS
  # enables OCSP stapling (so clients don't need contact the OCSP server -- i do instead)
  # - doesn't seem to, actually: <https://www.ssllabs.com/ssltest/analyze.html?d=uninsane.org>
  # caches TLS sessions for 10m
  services.nginx.recommendedTlsSettings = true;
  # enables sendfile, tcp_nopush, tcp_nodelay, keepalive_timeout 65
  services.nginx.recommendedOptimisation = true;


  # serve any site not otherwise declared, if it's static.
  # because we define it dynamically, SSL isn't trivial. support only http
  # documented <https://nginx.org/en/docs/http/ngx_http_core_module.html#server_name>
  services.nginx.virtualHosts."~^(?<domain>.+)$" = {
    default = true;
    addSSL = true;
    enableACME = false;
    sslCertificate = "/var/www/certs/wildcard/cert.pem";
    sslCertificateKey = "/var/www/certs/wildcard/key.pem";
    # sslCertificate = "/var/lib/acme/.minica/cert.pem";
    # sslCertificateKey = "/var/lib/acme/.minica/key.pem";
    # serverName = null;
    locations."/" = {
      # somehow this doesn't escape -- i get error 400 if i:
      # curl 'http://..' --resolve '..:80:127.0.0.1'
      root = "/var/www/sites/$domain";
      # tryFiles = "$domain/$uri $domain/$uri/ =404";
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "admin.acme@uninsane.org";

  sane.persist.sys.byStore.plaintext = [
    { user = "acme"; group = "acme"; path = "/var/lib/acme"; method = "bind"; }
  ];
  sane.persist.sys.byStore.private = [
    { user = "colin"; group = "users"; path = "/var/www/sites"; method = "bind"; }
  ];
  sane.persist.sys.byStore.ephemeral = [
    # logs *could* be persisted to private storage, but then there's the issue of
    # "what if servo boots, isn't unlocked, and the whole / tmpfs is consumed by logs"
    { user = "nginx"; group = "nginx"; path = "/var/log/nginx"; method = "bind"; }
  ];

  # create a self-signed SSL certificate for use with literally any domain.
  # browsers will reject this, but proxies and local testing tools can be configured
  # to accept it.
  system.activationScripts.generate-x509-self-signed.text = ''
    mkdir -p /var/www/certs/wildcard
    test -f /var/www/certs/wildcard/key.pem || ${lib.getExe pkgs.openssl} \
      req -x509 -newkey rsa:4096 \
      -keyout /var/www/certs/wildcard/key.pem \
      -out /var/www/certs/wildcard/cert.pem \
      -sha256 -nodes -days 3650 \
      -addext 'subjectAltName=DNS:*' \
      -subj '/CN=self-signed'
    chmod 640 /var/www/certs/wildcard/{key,cert}.pem
    chown root:nginx /var/www/certs/wildcard /var/www/certs/wildcard/{key,cert}.pem
  '';
}
