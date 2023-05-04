# docs: https://nixos.wiki/wiki/Nginx
{ config, lib, pkgs, ... }:

let
  # make the logs for this host "public" so that they show up in e.g. metrics
  publog = vhost: lib.attrsets.unionOfDisjoint vhost {
    extraConfig = (vhost.extraConfig or "") + ''
      access_log /var/log/nginx/public.log vcombined;
    '';
  };

  # kTLS = true;  # in-kernel TLS for better perf
in
{

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx.enable = true;
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
  # sets gzip_comp_level = 5
  services.nginx.recommendedGzipSettings = true;
  # enables OCSP stapling (so clients don't need contact the OCSP server -- i do instead)
  # - doesn't seem to, actually: <https://www.ssllabs.com/ssltest/analyze.html?d=uninsane.org>
  # caches TLS sessions for 10m
  services.nginx.recommendedTlsSettings = true;
  # enables sendfile, tcp_nopush, tcp_nodelay, keepalive_timeout 65
  services.nginx.recommendedOptimisation = true;

  # web blog/personal site
  services.nginx.virtualHosts."uninsane.org" = publog {
    root = "${pkgs.uninsane-dot-org}/share/uninsane-dot-org";
    # a lot of places hardcode https://uninsane.org,
    # and then when we mix http + non-https, we get CORS violations
    # and things don't look right. so force SSL.
    forceSSL = true;
    enableACME = true;
    # inherit kTLS;
    # for OCSP stapling
    sslTrustedCertificate = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    # uninsane.org/share/foo => /var/lib/uninsane/root/share/foo.
    # yes, nginx does not strip the prefix when evaluating against the root.
    locations."/share".root = "/var/lib/uninsane/root";

    # allow matrix users to discover that @user:uninsane.org is reachable via matrix.uninsane.org
    locations."= /.well-known/matrix/server".extraConfig =
      let
        # use 443 instead of the default 8448 port to unite
        # the client-server and server-server port for simplicity
        server = { "m.server" = "matrix.uninsane.org:443"; };
      in ''
        add_header Content-Type application/json;
        return 200 '${builtins.toJSON server}';
      '';
    locations."= /.well-known/matrix/client".extraConfig =
      let
        client = {
          "m.homeserver" =  { "base_url" = "https://matrix.uninsane.org"; };
          "m.identity_server" =  { "base_url" = "https://vector.im"; };
        };
      # ACAO required to allow element-web on any URL to request this json file
      in ''
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '${builtins.toJSON client}';
      '';

    # static URLs might not be aware of .well-known (e.g. registration confirmation URLs),
    # so hack around that.
    locations."/_matrix" = {
      proxyPass = "http://127.0.0.1:8008";
    };
    locations."/_synapse" = {
      proxyPass = "http://127.0.0.1:8008";
    };

    # allow ActivityPub clients to discover how to reach @user@uninsane.org
    # TODO: waiting on https://git.pleroma.social/pleroma/pleroma/-/merge_requests/3361/
    # locations."/.well-known/nodeinfo" = {
    #   proxyPass = "http://127.0.0.1:4000";
    #   extraConfig = pleromaExtraConfig;
    # };
  };


  # serve any site not listed above, if it's static.
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

  sane.persist.sys.plaintext = [
    # TODO: mode?
    { user = "acme"; group = "acme"; directory = "/var/lib/acme"; }
    { user = "colin"; group = "users"; directory = "/var/www/sites"; }
  ];

  # let's encrypt default chain looks like:
  # - End-entity certificate ← R3 ← ISRG Root X1 ← DST Root CA X3
  # - <https://community.letsencrypt.org/t/production-chain-changes/150739>
  # DST Root CA X3 expired in 2021 (?)
  # the alternative chain is:
  # - End-entity certificate ← R3 ← ISRG Root X1 (self-signed)
  # using this alternative chain grants more compatibility for services like ejabberd
  # but might decrease compatibility with very old clients that don't get updates (e.g. old android, iphone <= 4).
  # security.acme.defaults.extraLegoFlags = [
  security.acme.certs."uninsane.org" = rec {
    # ISRG Root X1 results in lets encrypt sending the same chain as default,
    # just without the final ISRG Root X1 ← DST Root CA X3 link.
    # i.e. we could alternative clip the last item and achieve the exact same thing.
    extraLegoRunFlags = [
      "--preferred-chain" "ISRG Root X1"
    ];
    extraLegoRenewFlags = extraLegoRunFlags;
  };
  # TODO: alternatively, we could clip the last cert IF it's expired,
  # optionally outputting that to a new cert file.
  # security.acme.defaults.postRun = "";

  # create a self-signed SSL certificate for use with literally any domain.
  # browsers will reject this, but proxies and local testing tools can be configured
  # to accept it.
  system.activationScripts.generate-x509-self-signed.text = ''
    mkdir -p /var/www/certs/wildcard
    test -f /var/www/certs/wildcard/key.pem || ${pkgs.openssl}/bin/openssl \
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
