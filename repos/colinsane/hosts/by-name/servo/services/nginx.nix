# docs: <https://nixos.wiki/wiki/Nginx>
# docs: <https://nginx.org/en/docs/>
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
  # nginxStable is one release behind nginxMainline.
  # nginx itself recommends running mainline; nixos defaults to stable.
  # services.nginx.package = pkgs.nginxMainline;
  # XXX(2024-07-31): nixos defaults to zlib-ng -- supposedly more performant, but spams log with
  # "gzip filter failed to use preallocated memory: ..."
  services.nginx.package = pkgs.nginxMainline.override { zlib = pkgs.zlib; };
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
  services.nginx.recommendedZstdSettings = true;
  # enables OCSP stapling (so clients don't need contact the OCSP server -- i do instead)
  # - doesn't seem to, actually: <https://www.ssllabs.com/ssltest/analyze.html?d=uninsane.org>
  # caches TLS sessions for 10m
  services.nginx.recommendedTlsSettings = true;
  # enables sendfile, tcp_nopush, tcp_nodelay, keepalive_timeout 65
  services.nginx.recommendedOptimisation = true;

  # web blog/personal site
  # alternative way to link stuff into the share:
  # sane.fs."/var/www/sites/uninsane.org/share/Ubunchu".mount.bind = "/var/media/Books/Visual/HiroshiSeo/Ubunchu";
  # sane.fs."/var/media/Books/Visual/HiroshiSeo/Ubunchu".dir = {};
  services.nginx.virtualHosts."uninsane.org" = publog {
    # a lot of places hardcode https://uninsane.org,
    # and then when we mix http + non-https, we get CORS violations
    # and things don't look right. so force SSL.
    forceSSL = true;
    enableACME = true;
    # inherit kTLS;
    # for OCSP stapling
    sslTrustedCertificate = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    locations."/" = {
      root = "${pkgs.uninsane-dot-org}/share/uninsane-dot-org";
      tryFiles = "$uri $uri/ @fallback";
    };

    # unversioned files
    locations."@fallback" = {
      root = "/var/www/sites/uninsane.org";
      extraConfig = ''
        # instruct Google to not index these pages.
        # see: <https://developers.google.com/search/docs/crawling-indexing/robots-meta-tag#xrobotstag>
        add_header X-Robots-Tag 'none, noindex, nofollow';

        # best-effort attempt to block archive.org from archiving these pages.
        # reply with 403: Forbidden
        # User Agent is *probably* "archive.org_bot"; maybe used to be "ia_archiver"
        # source: <https://archive.org/details/archive.org_bot>
        # additional UAs: <https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker>
        #
        # validate with: `curl -H 'User-Agent: "bot;archive.org_bot;like: something else"' -v https://uninsane.org/dne`
        if ($http_user_agent ~* "(?:\b)archive.org_bot(?:\b)") {
          return 403;
        }
        if ($http_user_agent ~* "(?:\b)archive.org(?:\b)") {
          return 403;
        }
        if ($http_user_agent ~* "(?:\b)ia_archiver(?:\b)") {
          return 403;
        }
      '';
    };

    # uninsane.org/share/foo => /var/www/sites/uninsane.org/share/foo.
    # special-cased to enable directory listings
    locations."/share" = {
      root = "/var/www/sites/uninsane.org";
      extraConfig = ''
        # autoindex => render directory listings
        autoindex on;
        # don't follow any symlinks when serving files
        # otherwise it allows a directory escape
        disable_symlinks on;
      '';
    };
    locations."/share/Milkbags/" = {
      alias = "/var/media/Videos/Milkbags/";
      extraConfig = ''
        # autoindex => render directory listings
        autoindex on;
        # don't follow any symlinks when serving files
        # otherwise it allows a directory escape
        disable_symlinks on;
      '';
    };
    locations."/share/Ubunchu/" = {
      alias = "/var/media/Books/Visual/HiroshiSeo/Ubunchu/";
      extraConfig = ''
        # autoindex => render directory listings
        autoindex on;
        # don't follow any symlinks when serving files
        # otherwise it allows a directory escape
        disable_symlinks on;
      '';
    };

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
    # see: https://git.pleroma.social/pleroma/pleroma/-/merge_requests/3361/
    # not sure this makes sense while i run multiple AP services (pleroma, lemmy)
    # locations."/.well-known/nodeinfo" = {
    #   proxyPass = "http://127.0.0.1:4000";
    #   extraConfig = pleromaExtraConfig;
    # };

    # redirect common feed URIs to the canonical feed
    locations."= /atom".extraConfig = "return 301 /atom.xml;";
    locations."= /feed".extraConfig = "return 301 /atom.xml;";
    locations."= /feed.xml".extraConfig = "return 301 /atom.xml;";
    locations."= /rss".extraConfig = "return 301 /atom.xml;";
    locations."= /rss.xml".extraConfig = "return 301 /atom.xml;";
    locations."= /blog/atom".extraConfig = "return 301 /atom.xml;";
    locations."= /blog/atom.xml".extraConfig = "return 301 /atom.xml;";
    locations."= /blog/feed".extraConfig = "return 301 /atom.xml;";
    locations."= /blog/feed.xml".extraConfig = "return 301 /atom.xml;";
    locations."= /blog/rss".extraConfig = "return 301 /atom.xml;";
    locations."= /blog/rss.xml".extraConfig = "return 301 /atom.xml;";
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
