{
  lib,
  domains,
  proxied,
  vaculib,
  ...
}:
let
  enableKeylog = false;
  cleanName = name: lib.replaceStrings [ "-" " " ] [ "_" "_" ] name;
  aclName = config: "host_" + (cleanName config.name);
  backendName = config: "backend_" + (cleanName config.name);
  concatMap =
    sep: f: list:
    lib.concatStringsSep sep (map f list);
  mapLines = f: list: concatMap "\n" f list;
  certs = concatMap " " (d: "crt /certs/${d}/full.pem") domains;
in
''
  ${lib.optionalString enableKeylog ''
    # ssl keylogging
    global
      tune.ssl.keylog on
      lua-load ${vaculib.path ./sslkeylog.lua}
  ''}

  global
    close-spread-time 1s
    hard-stop-after 3s
    description "triple-dezert frontproxy"
    no insecure-fork-wanted
    log stdout format short daemon
    numa-cpu-mapping
    tune.listener.default-shards by-thread
    tune.ssl.lifetime 24h
    zero-warning
    log 127.0.0.1 syslog debug
    stats socket /run/haproxy/admin.sock user haproxy group haproxy mode 660 level admin


  defaults
    # https://world.hey.com/goekesmi/haproxy-chrome-tcp-preconnect-and-error-408-a-post-preserved-from-the-past-2497d1f7
    timeout server 30s
    timeout client 10s
    timeout connect 10s
    option http-ignore-probes

    timeout tunnel 1h
    log global
    mode http
    option httplog

  frontend main
    bind :80
    bind :443 ssl ${certs}

    mode http

    acl has_sni ssl_fc_sni -m found
    acl has_host_hdr req.fhdr(host) -m found

    http-request set-var(req.host) req.fhdr(host),host_only
    # Check whether the client is attempting domain fronting.
    acl ssl_sni_http_host_match ssl_fc_sni,strcmp(req.host) eq 0

  ${mapLines (c: "  " + ''acl ${aclName c} var(req.host) -m str "${c.domain}"'') proxied}

    http-after-response set-header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" if { ssl_fc }

    http-request deny status 400 if !{ req.fhdr_cnt(host) eq 1 }
    http-request deny status 421 if has_sni has_host_hdr !ssl_sni_http_host_match
    http-request return lf-string "%ci\n" content-type text/plain if { var(req.host) -m str "shelvacu.com" } { path /ip }
    http-request redirect scheme https code 301 if !{ ssl_fc }

    # garunteed ssl-only from here on

  ${mapLines (
    d:
    "  "
    + ''http-request redirect location "https://${d}%[capture.req.uri]" code 301 if { var(req.host) -m str "www.${d}" }''
  ) domains}
    http-request return string "Shelvacu is awesome" content-type text/plain if { path / } { var(req.host) -m str "shelvacu.com" }
    http-request return string "Jean-luc is awesome" content-type text/plain if { path / } { var(req.host) -m str "jean-luc.org" }

  ${mapLines (c: "  " + "http-request allow if ${aclName c}") proxied}
    http-request return status 404 string "not found" content-type text/plain

  ${mapLines (c: "  " + "use_backend ${backendName c} if ${aclName c}") proxied}

  ${concatMap "\n\n" (c: ''
    backend ${backendName c}
      mode http
      ${lib.optionalString c.forwardFor (
        "  option forwardfor\n"
        + "  option forwarded\n"
        + "  http-request add-header X-Forwarded-Proto https if { ssl_fc }\n"
        + "  http-request add-header X-Forwarded-Proto http unless { ssl_fc }\n"
      )}
      server main ${c.upstreamAddress} check maxconn ${builtins.toString c.maxConnections} ${
        if c.useSSL then "ssl verify none ssl-reuse" else "proto h1"
      }
  '') proxied}
''
