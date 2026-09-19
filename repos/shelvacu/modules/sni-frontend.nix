# A TLS front door for a machine that has one public address but serves names
# belonging to more than one host.
#
# nginx takes the public port, reads the server name out of the TLS handshake
# without decrypting anything, and hands the connection on untouched: to
# another machine for the names configured here, and to the local Caddy over a
# unix socket for everything else. Because nothing is terminated here, a name
# that lives elsewhere keeps its certificate and its private key there.
#
# Both destinations are told who the client really is with the PROXY protocol,
# which they have to be configured to expect — Caddy is handled below, and a
# passthrough target needs its own listener set up to trust this machine.
{
  config,
  lib,
  ...
}:
let
  cfg = config.vacu.sniFrontend;
  inherit (lib) mkOption types;
  # nginx identifiers can't hold the punctuation a server name does.
  upstreamName = name: "vacu_sni_" + lib.replaceStrings [ "." "-" "*" ] [ "_" "_" "_" ] name;
  caddyUpstream = "vacu_sni_caddy";
in
{
  options.vacu.sniFrontend = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to put an SNI-routing TLS front door on this host.";
    };

    ports = mkOption {
      type = types.listOf types.port;
      default = [ 443 ];
      description = ''
        TCP ports to front. Every one of them is routed by server name, so a
        port serving a passthrough name works the same as 443 does.

        Only TCP is fronted: QUIC carries its server name inside encrypted
        packets, so UDP is left alone and Caddy keeps serving HTTP/3 itself.
      '';
    };

    caddySocket = mkOption {
      type = types.str;
      default = "/run/caddy/tls.sock";
      description = ''
        Unix socket Caddy listens on instead of the fronted TCP ports. It is
        created inside Caddy's runtime directory and made group-readable so
        nginx can reach it.
      '';
    };

    httpPort = mkOption {
      type = types.nullOr types.port;
      default = 80;
      description = ''
        Plain HTTP port to relay to Caddy as well, or null to leave it alone.

        Binding Caddy's sites to a socket takes its HTTP server with them, and
        that server is what answers redirects and ACME's HTTP challenge — so
        unless it is relayed too, port 80 simply stops being served. The relay
        is a straight copy; there is no server name to route on.
      '';
    };

    caddyHttpSocket = mkOption {
      type = types.str;
      default = "/run/caddy/http.sock";
      description = "Unix socket carrying the relayed plain-HTTP traffic.";
    };

    quicBinds = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "udp/0.0.0.0" "udp/[::]" ];
      description = ''
        Extra addresses to add to Caddy's bind, for recovering HTTP/3.

        Empty by default because **moving Caddy to a unix socket gives up
        HTTP/3**: a socket carries no UDP, so QUIC has nowhere to land. Adding
        UDP addresses here does give Caddy a QUIC listener, but it also stops
        the PROXY-protocol wrapper from applying to the socket, which breaks
        every ordinary request — so treat this as an experiment, not a fix.

        Clients negotiate HTTP/3 and fall back to HTTP/2 on their own, so the
        cost of leaving this empty is a little performance, not reachability.
      '';
    };

    passthrough = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = lib.literalExpression ''
        { "matrix.example.com" = "10.0.0.5:443"; }
      '';
      description = ''
        Server names to hand to somewhere else, as name -> `host:port`. A
        connection matching one of these is relayed exactly as it arrived, so
        the far end does its own TLS.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.caddy.enable;
        message = "vacu.sniFrontend routes unmatched names to Caddy, so Caddy has to be enabled.";
      }
    ];

    services.nginx = {
      enable = true;
      # This host only proxies streams; it serves no HTTP itself.
      #
      # Each destination gets an upstream block rather than going straight into
      # the map: proxy_pass reads its argument at request time, where a bare
      # name would need a resolver, while an upstream is resolved once at
      # startup. So a passthrough target can be given as a hostname.
      streamConfig = ''
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: upstream: ''
            upstream ${upstreamName name} {
              server ${upstream};
            }
          '') cfg.passthrough
        )}
        upstream ${caddyUpstream} {
          server unix:${cfg.caddySocket};
        }

        map $ssl_preread_server_name $vacu_sni_upstream {
          ${lib.concatStringsSep "\n          " (
            lib.mapAttrsToList (name: _: "${name} ${upstreamName name};") cfg.passthrough
          )}
          default ${caddyUpstream};
        }

        ${lib.concatMapStringsSep "\n" (port: ''
          server {
            listen ${toString port};
            listen [::]:${toString port};
            ssl_preread on;
            proxy_protocol on;
            proxy_pass $vacu_sni_upstream;
          }
        '') cfg.ports}

        ${lib.optionalString (cfg.httpPort != null) ''
          upstream ${caddyUpstream}_http {
            server unix:${cfg.caddyHttpSocket};
          }

          server {
            listen ${toString cfg.httpPort};
            listen [::]:${toString cfg.httpPort};
            proxy_protocol on;
            proxy_pass ${caddyUpstream}_http;
          }
        ''}
      '';
    };

    # nginx reaches the socket through Caddy's group rather than by widening
    # the socket to everyone.
    users.users.${config.services.nginx.user}.extraGroups = [ config.services.caddy.group ];

    systemd.services.caddy.serviceConfig.RuntimeDirectory = lib.mkDefault "caddy";
    systemd.services.nginx = {
      after = [ "caddy.service" ];
      # nginx resolves the socket at startup, so it has to exist by then.
      requires = [ "caddy.service" ];
    };

    services.caddy.globalConfig = lib.mkAfter (''
      default_bind ${lib.concatStringsSep " " ([ "unix/${cfg.caddySocket}|0660" ] ++ cfg.quicBinds)}
      servers unix/${cfg.caddySocket}|0660 {
        listener_wrappers {
          # No allow list: reaching this socket already means getting past its
          # group, and a unix peer has no address to match on anyway.
          proxy_protocol
          tls
        }
      }
    ''
    + lib.optionalString (cfg.httpPort != null) ''
      # Caddy would put its own HTTP server on the socket above, where it would
      # collide with the TLS one, so the redirects it normally generates are
      # turned off and served by the site below instead — on its own socket,
      # reached by the plain relay.
      auto_https disable_redirects
      servers unix/${cfg.caddyHttpSocket}|0660 {
        listener_wrappers {
          proxy_protocol
        }
      }
    '');

    # Appended as raw Caddyfile rather than a virtualHost, so it stays clear of
    # whatever options a host layers onto its vhosts.
    services.caddy.extraConfig = lib.mkIf (cfg.httpPort != null) ''
      http:// {
        bind unix/${cfg.caddyHttpSocket}|0660
        redir https://{host}{uri} permanent
      }
    '';

    networking.firewall.allowedTCPPorts = cfg.ports ++ lib.optional (cfg.httpPort != null) cfg.httpPort;
  };
}
