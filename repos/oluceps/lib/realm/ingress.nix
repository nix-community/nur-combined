{
  config,
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
  ...
}:
let
  inherit (common)
    appName
    ingressPath
    activation
    hardened
    drainTimeout
    proxy
    proxyTarget
    ;
in
route: i:
let
  unit = "realm-ingress-${name}-${route}";
  ingressUser = if i.backendUser == null then user else i.backendUser;
in
outputs.merge (
  [
    (
      outputs.empty
      // {
        assertions = [
          {
            assertion = i.allowedIDs != [ ];
            message = "${unit}: an explicit nonempty allowedIDs list is required.";
          }
          {
            assertion = !i.privateLoopback || w.isolation.privateNetwork;
            message = "${unit}: privateLoopback requires a private namespace.";
          }
          {
            assertion =
              i.native
              || (
                i.target != null
                && (
                  lib.hasPrefix "unix:" i.target
                  || i.privateLoopback
                  || (i.hostLoopback && lib.hasPrefix "127.0.0.1:" i.target)
                )
              );
            message = "${unit}: backend must be a Unix socket or an explicit loopback adapter.";
          }
          {
            assertion =
              i.backendUser == null
              || (
                !i.native
                && i.target != null
                && i.backendUser != "root"
                && builtins.length i.allowedIDs == 1
                && lib.hasPrefix "unix:" i.target
              );
            message = "${unit}: peer authentication requires an unprivileged user, exactly one authorized identity and a Unix backend.";
          }
          {
            assertion =
              !i.native
              || (
                !w.isolation.privateNetwork
                && w.runtime != "container"
                && !i.privateLoopback
                && !i.hostLoopback
                && i.target == null
                && i.backendUser == null
                && (config.systemd.services.${appName w}.enable or false)
              );
            message = "${unit}: native ingress requires a declared networked application unit and no proxy backend options.";
          }
        ];
        # Ingress registration. allowedIDs is the complete authorization
        # policy; publishing the port does not grant access by itself.
        registrations = lib.optionalAttrs (!i.native) {
          ${unit} = {
            spiffeID = w.spiffeID;
            selectors = [
              "systemd:id:${unit}.service"
              "unix:user:${ingressUser}"
            ];
          };
        };
        publications.${i.service} = {
          unit = if i.native then w.unit else "${unit}.service";
          port = i.port;
          serverID = w.spiffeID;
          allowedIDs = i.allowedIDs;
        };
        sockets = lib.optionalAttrs (!i.native) {
          ${unit} = {
            wantedBy = [ "sockets.target" ];
            listenStreams = [ "[${cfg.address}]:${toString i.port}" ];
            socketConfig = {
              FileDescriptorName = "ingress";
              # Mesh addresses may be assigned after sockets.target during boot.
              FreeBind = true;
            };
          };
        };
        services = lib.optionalAttrs (!i.native) {
          ${unit} = {
            wantedBy = [ "multi-user.target" ];
            upheldBy = [ "spire-agent.service" ];
            requires = [
              "spire-agent.service"
              "${unit}.socket"
            ];
            after = [ "spire-agent.service" ];
            serviceConfig = hardened // {
              Type = "notify";
              TimeoutStartSec = "90s";
              User = ingressUser;
              Group = user;
              SupplementaryGroups = [ "realm-proxies" ] ++ w.ingressGroups;
              ExecStart = lib.escapeShellArgs (
                [
                  "${cfg.ghostunnelPackage}/bin/ghostunnel"
                  "server"
                  "--use-workload-api"
                  "--cacert"
                  "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                  "--use-workload-api-addr"
                  "unix://${cfg.spire.socket}"
                  "--listen"
                  "systemd:ingress"
                  "--target"
                  (if i.privateLoopback then "unix:${ingressPath name route}" else i.target)
                  "--max-conn-lifetime"
                  "1h"
                  "--shutdown-timeout"
                  drainTimeout
                ]
                ++ lib.optionals (cfg.spire.metrics.enable or false) [
                  "--status=https://127.0.0.1:${toString cfg.spire.metrics.statusPorts.${unit}}"
                ]
                ++ lib.concatMap (id: [
                  "--allow-uri"
                  id
                ]) i.allowedIDs
              );
            };
          };
        };
      }
    )
  ]
  # Ingress-side adapter. The backend keeps listening on loopback inside
  # the workload namespace, so ghostunnel reaches it through this socket
  # and the backend never sees the mesh address.
  ++ lib.optional i.privateLoopback (
    outputs.empty
    // {
      sockets."realm-backend-${name}-${route}" = {
        wantedBy = [ "sockets.target" ];
        listenStreams = [ (ingressPath name route) ];
        socketConfig = activation user user "backend";
      };
      services."realm-backend-${name}-${route}" = network // {
        requires = network.requires ++ [ w.unit ];
        after = network.after ++ [ w.unit ];
        serviceConfig = hardened // {
          User = user;
          Group = user;
          PrivateNetwork = true;
          ExecStart = "${proxy} ${proxyTarget i.target}";
        };
      };
    }
  )
)
