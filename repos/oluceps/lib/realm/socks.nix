{
  lib,
  pkgs,
  common,
  outputs,
}:
{
  name,
  w,
  network,
  ...
}:
let
  inherit (common)
    appName
    base
    activation
    hardened
    helper
    ;
in
outputs.merge (
  # gost turns the authenticated HTTP Internet egress into a SOCKS5
  # listener for applications that only speak SOCKS. UDP and BIND stay
  # disabled, so the adapter cannot be used as a general relay.
  (lib.optional w.socksProxy.enable (
    outputs.empty
    // {
      assertions = [
        {
          assertion =
            w.isolation.privateNetwork
            && w.runtime != "external"
            && (w.egress ? internet)
            && w.egress.internet.localPort != null;
          message = "realm.workloads.${name}: SOCKS adaptation requires a private namespace and an internet egress with localPort.";
        }
      ];
      services."realm-socks-${name}" = network // {
        requires = network.requires ++ [ "realm-local-${name}-internet.socket" ];
        after = network.after ++ [ "realm-local-${name}-internet.socket" ];
        serviceConfig = hardened // {
          User = w.user;
          Group = w.group;
          PrivateNetwork = true;
          ExecStart = lib.escapeShellArgs [
            "${pkgs.gost}/bin/gost"
            "-L"
            "socks5://127.0.0.1:${toString w.socksProxy.port}?notls=true&bind=false&udp=false"
            "-F"
            "http://127.0.0.1:${toString w.egress.internet.localPort}"
          ];
          ExecStartPost = pkgs.writeShellScript "wait-realm-socks-${name}" ''
            for attempt in $(${pkgs.coreutils}/bin/seq 1 50); do
              if ${pkgs.netcat-openbsd}/bin/nc -z -w 1 127.0.0.1 ${toString w.socksProxy.port}; then exit 0; fi
              ${pkgs.coreutils}/bin/sleep 0.1
            done
            exit 1
          '';
        };
      };
      services.${appName w} = {
        requires = [ "realm-socks-${name}.service" ];
        after = [ "realm-socks-${name}.service" ];
      };
    }
  ))
  # A container cannot join the namespace listener, so it receives the
  # same SOCKS port over a mounted Unix socket instead.
  ++ lib.optional (w.socksProxy.enable && w.runtime == "container") (
    outputs.empty
    // {
      sockets."realm-socks-unix-${name}" = {
        wantedBy = [ "sockets.target" ];
        listenStreams = [ "${base name}/egress/socks.sock" ];
        socketConfig = activation w.user w.group "socks";
      };
      services."realm-socks-unix-${name}" = network // {
        requires = network.requires ++ [ "realm-socks-${name}.service" ];
        after = network.after ++ [ "realm-socks-${name}.service" ];
        serviceConfig = hardened // {
          User = w.user;
          Group = w.group;
          PrivateNetwork = true;
          ExecStart = lib.escapeShellArgs [
            "${helper}/bin/realm-helper"
            "bridge"
            "--target"
            "127.0.0.1:${toString w.socksProxy.port}"
          ];
        };
      };
    }
  )
)
