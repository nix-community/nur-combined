{ pkgs, ... }:
{
  # alternative way to link stuff into the share:
  # sane.fs."/var/www/sites/uninsane.org/share/Ubunchu".mount.bind = "/var/media/Books/Visual/HiroshiSeo/Ubunchu";
  # sane.fs."/var/media/Books/Visual/HiroshiSeo/Ubunchu".dir = {};
  services.nginx.virtualHosts."uninsane.org" = {
    # a lot of places hardcode https://uninsane.org,
    # and then when we mix http + non-https, we get CORS violations
    # and things don't look right. so force SSL.
    forceSSL = true;
    enableACME = true;

    # extraConfig = ''
    #   # "public" log so requests show up in goaccess metrics
    #   access_log /var/log/nginx/public.log vcombined;
    # '';

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
    locations."/_matrix".extraConfig = "return 301 https://matrix.uninsane.org$request_uri;";
    locations."/_synapse".extraConfig = "return 301 https://matrix.uninsane.org$request_uri;";

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
}
