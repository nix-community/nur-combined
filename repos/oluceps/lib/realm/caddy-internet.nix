{
  lib,
  nodeID,
  address,
  port,
  adminPort ? 19329,
  statusPort ? 19330,
  spiffeID,
  trustDomain,
  spireSocket,
  allowedIDs,
  extraConnectPorts ? { },
  extraConnectPolicies ? { },
}:
let
  # These rules precede the final allow-all rule. Only numeric addresses that
  # passed this ACL are dialed by forwardproxy; no second hostname lookup occurs.
  privateDestinations = [
    "0.0.0.0/8"
    "10.0.0.0/8"
    "100.64.0.0/10"
    "127.0.0.0/8"
    "169.254.0.0/16"
    "172.16.0.0/12"
    "192.0.0.0/24"
    "192.168.0.0/16"
    "198.18.0.0/15"
    "224.0.0.0/4"
    "240.0.0.0/4"
    "::/128"
    "::1/128"
    # net.IPNet matches IPv4-mapped addresses against the IPv4 rules above.
    # ::ffff:0:0/96 itself would collapse to 0.0.0.0/0 and deny all IPv4.
    "200::/7"
    "fc00::/7"
    "fe80::/10"
    "fec0::/10"
    "ff00::/8"
  ];
  acl = [
    {
      subjects = privateDestinations;
      allow = false;
    }
    {
      subjects = [ "all" ];
      allow = true;
    }
  ];
  forwardProxy = ports: {
    handler = "forward_proxy";
    inherit acl;
    allowed_ports = lib.unique ports;
    dial_timeout = "10s";
  };
  identity = id: {
    vars_regexp."{http.request.tls.client.san.uris.0}".pattern = "^${lib.escapeRegex id}$";
  };
  policies =
    builtins.attrValues extraConnectPolicies
    ++ lib.mapAttrsToList (id: ports: {
      identities = [ id ];
      inherit ports;
    }) extraConnectPorts;
  extraIDs = lib.unique (lib.concatMap (policy: policy.identities) policies);
  # Combine grants before emitting routes. First-match routing must not hide a
  # second policy that grants another port to the same authenticated identity.
  portsFor =
    id:
    [ 443 ]
    ++ lib.concatMap (policy: policy.ports) (
      builtins.filter (policy: builtins.elem id policy.identities) policies
    );
  denied = {
    handler = "static_response";
    status_code = 403;
  };
  certSubject = "internet-${nodeID}";
  mtls = ids: {
    automatic_https.disable = true;
    strict_sni_host = false;
    tls_connection_policies = [
      {
        default_sni = certSubject;
        protocol_min = "tls1.3";
        client_authentication = {
          mode = "require";
          verifiers = [
            {
              verifier = "spiffe";
              socket_path = spireSocket;
              allowed_ids = ids;
            }
          ];
        };
      }
    ];
  };
in
{
  # Expose only explicit /metrics and SVID observation listeners on loopback.
  # No Caddy configuration API is available to the proxy or its callers.
  admin.disabled = true;
  apps = {
    tls.automation.policies = [
      {
        get_certificate = [
          {
            via = "spiffe";
            socket_path = spireSocket;
            spiffe_id = spiffeID;
          }
        ];
      }
    ];
    http = {
      metrics = { };
      servers = {
        internet = mtls allowedIDs // {
          listen = [ "${if lib.hasInfix ":" address then "[${address}]" else address}:${toString port}" ];
          logs = { };
          routes = [
            {
              handle = [
                {
                  handler = "log_append";
                  key = "caller_spiffe_id";
                  value = "{http.request.tls.client.san.uris.0}";
                  early = true;
                }
              ];
            }
          ]
          ++ map (id: {
            match = [ (identity id // { method = [ "CONNECT" ]; }) ];
            handle = [ (forwardProxy (portsFor id)) ];
            terminal = true;
          }) extraIDs
          ++ [
            {
              match = [ { method = [ "CONNECT" ]; } ];
              handle = [ (forwardProxy [ 443 ]) ];
              terminal = true;
            }
            {
              # forwardproxy buffers bodies on these idempotent methods.
              # Bound that allocation while leaving streamed uploads unchanged.
              match = [
                {
                  method = [
                    "GET"
                    "HEAD"
                    "OPTIONS"
                    "TRACE"
                  ];
                }
              ];
              handle = [
                {
                  handler = "request_body";
                  max_size = 8388608;
                }
                (forwardProxy [
                  80
                  443
                ])
              ];
              terminal = true;
            }
            {
              handle = [
                (forwardProxy [
                  80
                  443
                ])
              ];
              terminal = true;
            }
          ];
        };
        metrics = {
          listen = [ "127.0.0.1:${toString adminPort}" ];
          automatic_https.disable = true;
          routes = [
            {
              match = [
                {
                  path = [ "/metrics" ];
                  method = [ "GET" ];
                }
              ];
              handle = [ { handler = "metrics"; } ];
            }
            { handle = [ denied ]; }
          ];
        };
        identity-svid = mtls [ "spiffe://${trustDomain}/observer/identity/${nodeID}" ] // {
          listen = [ "127.0.0.1:${toString statusPort}" ];
          routes = [
            {
              match = [
                {
                  path = [ "/" ];
                  method = [ "GET" ];
                }
              ];
              handle = [
                {
                  handler = "static_response";
                  status_code = 204;
                }
              ];
            }
            { handle = [ denied ]; }
          ];
        };
      };
    };
  };
}
