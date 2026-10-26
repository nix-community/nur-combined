{ lib, cfg }:
let
  inherit (lib) mkOption types;
  endpointType = types.submodule (
    { name, ... }:
    {
      options = {
        # Service name in the declarative ingress catalog.
        service = mkOption { type = types.str; };
        # Exact URI SAN expected from the peer; DNS cannot override it.
        verifyID = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        node = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        target = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Fixed TLS destination as host:port or unix:/path, instead of the declarative catalog.";
        };
        # Use an existing socket instead of the generated path, when another
        # module owns the listener.
        socket = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        localPort = mkOption {
          type = types.nullOr types.port;
          default = null;
          description = "Optional loopback adapter inside the workload namespace.";
        };
      };
    }
  );
  ingressType = types.submodule {
    options = {
      # Port on the node's mesh address; the published SRV record uses it.
      port = mkOption { type = types.port; };
      # Plaintext backend the ingress process dials after terminating mTLS.
      target = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      native = mkOption {
        type = types.bool;
        default = false;
        description = "The application terminates SPIFFE mTLS and enforces allowedIDs itself, using the Agent SDS API.";
      };
      # Service name this ingress publishes for SRV discovery.
      service = mkOption { type = types.str; };
      # Callers ghostunnel (or the native application) accepts. The module
      # rejects an empty list, so access is always stated explicitly.
      allowedIDs = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      privateLoopback = mkOption {
        type = types.bool;
        default = false;
        description = "Reach a TCP backend through a socket-activated adapter in the workload namespace.";
      };
      hostLoopback = mkOption {
        type = types.bool;
        default = false;
        description = "Explicit host-loopback backend for a public edge or Internet gateway.";
      };
      backendUser = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Run this ingress as a dedicated local user to preserve Unix peer authentication.";
      };
    };
  };
  workloadType = types.attrsOf (
    types.submodule (
      { name, ... }:
      {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
          };
          # Application unit whose sandbox and dependencies are configured.
          unit = mkOption {
            type = types.strMatching ".+\\.service";
            default = "${name}.service";
          };
          # Account the application itself runs as.
          user = mkOption {
            type = types.str;
            default = name;
          };
          group = mkOption {
            type = types.str;
            default = name;
          };
          # systemd:    the module builds the sandbox, sockets and adapters.
          # container:  the container engine mounts the egress sockets.
          # external:   only DNS, registrations and egress helpers are
          #             generated; the application is wired elsewhere.
          runtime = mkOption {
            type = types.enum [
              "systemd"
              "container"
              "external"
            ];
            default = "systemd";
          };
          # Identity shared by every process of this workload; declaring the
          # same ID twice merges their authorization.
          spiffeID = mkOption {
            type = types.str;
            default = "${cfg.servicePrefix}${name}";
          };
          isolation = {
            # Remove the route to the host and the Internet. Disable it only
            # for an edge or gateway role that must accept public traffic.
            privateNetwork = mkOption {
              type = types.bool;
              default = true;
            };
            # Additional host runtime paths the application may use, e.g.
            # journal sockets for log collection.
            allowUnixSockets = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
            hosts = mkOption {
              type = types.attrsOf types.str;
              default = { };
              description = "Workload-local host aliases, preserving TLS names when dialing private egress adapters.";
            };
            runtimePaths = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
          };
          # Extra groups allowed to connect to this workload's ingress
          # sockets; the proxy group is always included.
          ingressGroups = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
          egress = mkOption {
            type = types.attrsOf endpointType;
            default = { };
          };
          ingress = mkOption {
            type = types.attrsOf ingressType;
            default = { };
          };
          # SOCKS5 adapter for clients that cannot use an HTTP proxy.
          socksProxy = {
            enable = lib.mkEnableOption "a local SOCKS5 adapter through the authenticated HTTP Internet egress";
            port = mkOption {
              type = types.port;
              default = 11080;
            };
          };
        };
      }
    )
  );
in
{
  inherit endpointType ingressType workloadType;
}
