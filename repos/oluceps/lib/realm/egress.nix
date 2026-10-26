{
  lib,
  pkgs,
  cfg,
  common,
  outputs,
}:
{
  name,
  w,
  user,
  network,
  egressSocket,
}:
let
  inherit (common)
    resolve
    activation
    hardened
    drainTimeout
    proxy
    ;
in
route: e:
let
  unit = "realm-egress-${name}-${route}";
  endpoint = resolve {
    inherit (e)
      service
      node
      target
      verifyID
      ;
  };
in
outputs.merge (
  [
    (
      outputs.empty
      // {
        assertions = [
          {
            assertion = endpoint.unambiguous;
            message = "${unit}: service ${e.service} must have exactly one catalog endpoint, or set an explicit target.";
          }
          {
            assertion = endpoint.hasIdentity;
            message = "${unit}: the destination must have an explicit SPIFFE ID or a catalog serverID.";
          }
          {
            assertion = endpoint.transportMatches;
            message = "${unit}: the endpoint must use SPIFFE TLS.";
          }
          {
            assertion = endpoint.identityMatches;
            message = "${unit}: verifyID must match the catalog serverID.";
          }
          {
            assertion = e.localPort == null || w.isolation.privateNetwork;
            message = "${unit}: localPort requires a private namespace.";
          }
        ];
        # Registration of the egress proxy. Both selectors are required:
        # systemd creates the socket first and only then starts the proxy as
        # the workload's proxy account, and SPIRE must observe both facts.
        registrations.${unit} = {
          spiffeID = w.spiffeID;
          selectors = [
            "systemd:id:${unit}.service"
            "unix:user:${user}"
          ];
        };
        sockets.${unit} = {
          wantedBy = [ "sockets.target" ];
          listenStreams = [ (egressSocket route e) ];
          socketConfig = activation user w.group "egress";
        };
        services.${unit} = {
          requires = [ "spire-agent.service" ];
          after = [ "spire-agent.service" ];
          serviceConfig = hardened // {
            Type = "notify";
            NotifyAccess = "all";
            TimeoutStartSec = "90s";
            User = user;
            Group = user;
            SupplementaryGroups = [ "realm-proxies" ];
            # ghostunnel fetches the SVID and trust bundle from the Agent,
            # verifies the peer URI SAN and serves plaintext on the egress
            # socket. A one-hour connection lifetime bounds the effect of a
            # later policy change; certificate expiry alone closes nothing.
            ExecStart = lib.escapeShellArgs ([
              "${cfg.ghostunnelPackage}/bin/ghostunnel"
              "client"
              "--use-workload-api"
              "--cacert"
              "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              "--use-workload-api-addr"
              "unix://${cfg.spire.socket}"
              "--listen"
              "systemd:egress"
              "--verify-uri"
              endpoint.serverID
              "--max-conn-lifetime"
              "1h"
              "--shutdown-timeout"
              drainTimeout
              "--target"
              endpoint.target
            ]);
          };
        };
      }
    )
  ]
  # Loopback adapter for clients that cannot use Unix sockets. It
  # exists only inside the workload namespace, so 127.0.0.1:<localPort>
  # is unreachable from the host and from other workloads.
  ++
    lib.optional
      (e.localPort != null && (w.runtime == "systemd" || (w.socksProxy.enable && route == "internet")))
      (
        outputs.empty
        // {
          sockets."realm-local-${name}-${route}" = network // {
            wantedBy = [ "sockets.target" ];
            listenStreams = [ "127.0.0.1:${toString e.localPort}" ];
            socketConfig = {
              PrivateNetwork = true;
            };
          };
          services."realm-local-${name}-${route}" = network // {
            serviceConfig = hardened // {
              User = user;
              Group = user;
              SupplementaryGroups = [ w.group ];
              PrivateNetwork = true;
              ExecStart = "${proxy} ${egressSocket route e}";
            };
          };
        }
      )
)
