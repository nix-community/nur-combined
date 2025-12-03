{ config, lib, pkgs, sane-lib, ... }:
let
  cfg = config.sane.netns;
  nsIpv4 = builtins.head (builtins.filter
    (ns: (builtins.match "[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+" ns) != null)
    config.networking.nameservers ++ lib.optionals config.networking.resolvconf.useLocalResolver [
      "127.0.0.1" "::1"
    ]
  );
  netnsOpts = with lib; types.submodule {
    options = {
      dns.ipv4 = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          rewrite all DNS queries inside the netns to some target address.
          set to veth.netns.ipv4 and run a resolver in the parent namespace
          to resolve DNS queries in cleartext,
          or set to your VPN provider's DNS servers to resolve over wireguard.
        '';
      };
      veth.initns.ipv4 = mkOption {
        type = types.str;
      };
      veth.netns.ipv4 = mkOption {
        type = types.str;
      };
      routeTable = mkOption {
        type = types.int;
        description = ''
          numeric ID for iproute2 (0-255?).
          each netns gets its own routing table so that i can route a packet out by placing it in the table.
        '';
      };
      wg.port = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = ''
          fixed port to listen to,
          or null to listen on a random unused port.
        '';
      };
      wg.privateKeyFile = mkOption {
        type = types.path;
      };
      wg.address.ipv4 = mkOption {
        type = types.str;
      };
      wg.peer.publicKey = mkOption {
        type = types.str;
      };
      wg.peer.endpoint = mkOption {
        type = types.str;
      };

      services = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          list of services to run inside this net namespace.
          does not configure any wantedBy dependency, just ensures that said service is started inside this NS if/when it is started.
        '';
      };
    };
  };
  mkNetNsConfig = name: opts: with opts; let
    ip = lib.getExe' pkgs.iproute2 "ip";
    iptables = lib.getExe' pkgs.iptables "iptables";
    in-ns = "${ip} netns exec ${name}";
    wg' = lib.getExe' pkgs.wireguard-tools "wg";
  in {
    systemd.targets."netns-${name}" = {
      description = "create a network namespace which will selectively bridge traffic with the init namespace";
      wantedBy = [ "default.target" ];
    };
    systemd.services."netns-${name}" = {
      description = "create an empty network namespace for ${name}";
      wantedBy = [ "netns-${name}.target" ];
      before = [ "netns-${name}.target" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      serviceConfig.X-RestartIfChanged = false;  #< never restart on deploy
      script = ''
        ${ip} netns add ${name} || (test -e /run/netns/${name} && echo "${name} already exists")
      '';
      serviceConfig.ExecStop = [
        "${ip} netns delete ${name}"
      ];
    };
    # loopback is tricky:
    # - we _don't_ want a 127.0.0.1 address, in order that we can forward DNS queries to the outer NS.
    # - we _do_ want a `lo` device, as local communications within the netns will use it as source:
    #   - e.g. `ip route get 10.0.1.6` will show `dev lo` even if `lo` is down.
    systemd.services."netns-${name}-lo" = {
      description = "bring loopback device online in '${name}' network namespace";
      wantedBy = [ "netns-${name}.target" ];
      before = [ "netns-${name}.target" ];
      after = [ "netns-${name}.service" ];
      partOf = [ "netns-${name}.service" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      serviceConfig.NetworkNamespacePath = "/run/netns/${name}";
      script = ''
        ${ip} link set lo up
        # N.B.: these addresses are implicitly assigned when the interface transitions down -> up.
        # so unfortunately, we have a blip here where the addresses are briefly assigned, then removed.
        ${ip} addr del 127.0.0.1/8 dev lo || echo "lo IPv4 address already removed"
        ${ip} addr del ::1/128 dev lo || echo "lo IPv6 address already removed"
      '';
      serviceConfig.ExecStop = "${ip} link set lo down";
    };
    systemd.services."netns-${name}-veth" = {
      description = "create a link between ${name} and the parent net namespace which tunnels any traffic explicitly routed to it";
      wantedBy = [ "netns-${name}.target" ];
      before = [ "netns-${name}.target" ];
      after = [ "netns-${name}.service" ];
      partOf = [ "netns-${name}.service" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = ''
        # DOCS:
        # - some of this approach is described here: <https://josephmuia.ca/2018-05-16-net-namespaces-veth-nat/>
        # - iptables primer: <https://danielmiessler.com/study/iptables/>
        # create veth pair
        ${ip} link add ${name}-veth-a type veth peer name ${name}-veth-b || echo "${name}-veth-{a,b} aleady exists"
        ${ip} addr add ${veth.initns.ipv4}/24 dev ${name}-veth-a || echo "${name}-veth-a aleady has IP address"
        ${ip} link set ${name}-veth-a up

        # move veth-b into the namespace
        ${ip} link set ${name}-veth-b netns ${name} || echo "${name}-veth-b was already moved into its netns"
        ${in-ns} ${ip} addr add ${veth.netns.ipv4}/24 dev ${name}-veth-b || echo "${name}-veth-b aleady has IP address"
        ${in-ns} ${ip} link set ${name}-veth-b up

        # make it so traffic originating from the host side of the veth
        # is sent over the veth no matter its destination (well, unless it's to another interface that exists on the host).
        ${ip} rule add from ${veth.initns.ipv4} lookup ${name} pref 50 || echo "${name} already has ip rules (pref 50)"
        ${ip} route add default via ${veth.netns.ipv4} dev ${name}-veth-a proto kernel src ${veth.initns.ipv4} table ${name} || \
          echo "${name} already has default route"
      '';
      serviceConfig.ExecStopPost = [
        "-${in-ns} ${ip} link del ${name}-veth-b"
        "-${ip} link del ${name}-veth-a"
        # restore rules/routes
        "-${ip} rule del from ${veth.initns.ipv4} lookup ${name} pref 50"
        "-${ip} route del default via ${veth.netns.ipv4} dev ${name}-veth-a proto kernel src ${veth.initns.ipv4} table ${name}"
      ];
    };
    systemd.services."netns-${name}-forwards" = {
      description = "automatically NAT specific traffic encounted inside the net namespace up to the host for handling";
      wantedBy = [ "netns-${name}.target" ];
      before = [ "netns-${name}.target" ];
      after = [ "netns-${name}-veth.service" ];
      partOf = [ "netns-${name}.service" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;

      serviceConfig.NetworkNamespacePath = "/run/netns/${name}";
      script = let
        portsToBridge = lib.filterAttrs
          (port: portCfg: portCfg.visibleTo."${name}")
          config.sane.ports.ports
        ;
        bridgePort = port: proto: ''
          ${iptables} -A PREROUTING -t nat -p ${proto} --dport ${port} -m iprange --dst-range ${wg.address.ipv4} \
            -j DNAT --to-destination ${veth.initns.ipv4}
        '';
        bridgeStatements = lib.foldlAttrs
          (acc: port: portCfg: acc ++ (builtins.map (bridgePort port) portCfg.protocol))
          []
          portsToBridge
        ;
      in
        lib.concatStringsSep "\n" bridgeStatements
      ;
    };
    systemd.services."netns-${name}-dns" = lib.mkIf (dns.ipv4 != null) {
      description = "forward DNS requests from any programs running inside the net namespace to a DNS server capable of servicing them";
      wantedBy = [ "netns-${name}.target" ];
      before = [ "netns-${name}.target" ];
      after = [ "netns-${name}.service" ];
      partOf = [ "netns-${name}.service" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;

      serviceConfig.NetworkNamespacePath = "/run/netns/${name}";
      # in order to access DNS in this netns, we need to route it to the VPN's nameservers
      serviceConfig.ExecStart = "${iptables} -A OUTPUT -t nat -p udp --dport 53 -m iprange --dst-range ${nsIpv4}    -j DNAT --to-destination ${dns.ipv4}:53";
      serviceConfig.ExecStop = "${iptables} -D OUTPUT -t nat -p udp --dport 53 -m iprange --dst-range ${nsIpv4}    -j DNAT --to-destination ${dns.ipv4}:53";
    };

    systemd.services."netns-${name}-wg" = {
      description = "configure the wireguard device which provides ${name} with an IP";
      wantedBy = [ "netns-${name}.target" ];
      partOf = [ "netns-${name}.service" ];
      before = [ "netns-${name}.target" ];
      after = [
        "netns-${name}.service"
        # in case the endpoint is a domain or host name, wait for the DNS resolver to be available
        # before even trying configure the device. not strictly necessary, just avoids wasting resources/retries.
        "nss-lookup.target"
      ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      serviceConfig.Restart = "on-failure";
      serviceConfig.RestartSec = "10s";
      serviceConfig.RestartMaxDelaySec = "180s";
      serviceConfig.RestartSteps = 9; # roughly: 10s, 30s, 50s, ... 180s, then keep the 180s retry
      script = ''
        ${ip} link add wg-${name} type wireguard

        ${lib.optionalString (wg.port != null) ''
          # listen on a public port. the other end of the tunnel doesn't send keepalives
          # so i *hope* setting to a fixed port, which is opened in `sane.ports.ports`, makes the tunnel more robust
          ${wg'} set wg-${name} listen-port ${builtins.toString wg.port}
        ''}

        # resolve the endpoint *now*, from a namespace which can do DNS lookups, before moving it into its destination netns
        # at this point, our wg device can neither send nor receive traffic, because we haven't given it a private key.
        # hence, it's 100% safe to configure peers even inside the root ns at this point.
        #
        # N.B.: `wg` resolves the endpoint _immediately_; it doesn't save DNS info into the device at all,
        # so the possibility of any code not visible here trying to re-resolve the endpoint at a later time
        # (i.e. from within the namespace) is 0.
        ${wg'} set wg-${name} peer ${wg.peer.publicKey} endpoint ${wg.peer.endpoint} \
          persistent-keepalive 25 \
          allowed-ips 0.0.0.0/0,::/0

        ${ip} link set wg-${name} netns ${name}

        ${in-ns} ${wg'} set wg-${name} private-key ${wg.privateKeyFile}
        ${in-ns} ${ip} address add ${wg.address.ipv4} dev wg-${name}
        ${in-ns} ${ip} link set up dev wg-${name}

        # in the namespace, make this device the default route
        ${in-ns} ${ip} route replace 0.0.0.0/0 dev wg-${name} table main
      '';
      serviceConfig.ExecStopPost = [
        # gracefully bring the tunnel down (`-` to silence errors).
        # do the reverse actions as in `ExecStart`, one-for-one, for the benefit of debuggability
        "-${in-ns} ${ip} route delete 0.0.0.0/0 dev wg-${name} table main"
        "-${in-ns} ${ip} link set down dev wg-${name}"
        "-${in-ns} ${ip} address del ${wg.address.ipv4} dev wg-${name}"
        "-${in-ns} ${wg'} set wg-${name} private-key /dev/null"
        "-${in-ns} ${wg'} set wg-${name} peer ${wg.peer.publicKey} remove"
        # delete the tunnel (first, in the root ns in case we raced)
        "-${ip} link del wg-${name}"
        # delete the tunnel (the one that should actually exist)
        "${in-ns} ${ip} link del wg-${name}"
      ];
    };

    sane.ports.ports = lib.optionalAttrs (wg.port != null) {
      "${builtins.toString wg.port}" = {
        protocol = [ "udp" ];
        visibleTo.lan = true;
        visibleTo.wan = true;
        # visibleTo.doof = true;
        description = "colin-wireguard-${name}";
      };
    };

    # SPECULATIVE: i think my wireguard tunnels are breaking when the WAN changes.
    # this might fix it, but maybe i need more extensive monitoring of the handshake field in
    # `sudo ip netns exec doof wg show`
    sane.services.dyn-dns.restartOnChange = [ "netns-${name}-wg.service" ];

    # for some reason network-pre doesn't actually get run before network.target by default??
    systemd.targets.network-pre.wantedBy = [ "network.target" ];
    systemd.targets.network-pre.before = [ "network.target" ];

    # i want IP routes such that any packets sent from the initns veth -- regardless of destination -- are tunneled through the VPN.
    # that's source policy routing. normal `ip route` only allows routing based on the destination address.
    #
    # to achieve source policy routing:
    # - create a new routing table.
    # - `ip rule` which assigns every packet with matching source into that routing table.
    # - within the routing table, use ordinary destination policy routing.
    #
    # each routing table has a numeric ID associated with it. i think the number doesn't impact anything, it just needs to be unique.
    networking.iproute2.rttablesExtraConfig = ''
      ${builtins.toString routeTable} ${name}
    '';
    networking.iproute2.enable = true;
  };

  mkNetNsConfig' = name: opts: let
    nsConfig = mkNetNsConfig name opts;
  in nsConfig // {
    systemd = nsConfig.systemd // {
      services = lib.mkMerge [
        nsConfig.systemd.services
        (lib.genAttrs opts.services (svc: {
          after = [ "netns-${name}.target" ];
          partOf = [ "netns-${name}.service" ];
          serviceConfig.NetworkNamespacePath = "/run/netns/${name}";
          # abort if public IP is not as expected.
          # copy this snippet to the service definition site if you want it: it has to be defined as close to the service definition as possible to be useful
          # serviceConfig.ExecStartPre = [
          #   "${lib.getExe pkgs.sane-scripts.ip-check} --no-upnp --expect ${opts.address.ipv4}"
          # ];
        }))
      ];
    };
  };
in
{
  options = with lib; {
    sane.netns = mkOption {
      type = types.attrsOf netnsOpts;
      default = {};
    };
  };

  config = let
    configs = lib.mapAttrsToList mkNetNsConfig' cfg;
    take = f: {
      networking.localCommands = f.networking.localCommands;
      networking.iproute2.rttablesExtraConfig = f.networking.iproute2.rttablesExtraConfig;
      networking.iproute2.enable = f.networking.iproute2.enable;
      sane.ports.ports = f.sane.ports.ports;
      sane.services.dyn-dns = f.sane.services.dyn-dns;
      systemd.services = f.systemd.services;
      systemd.targets = f.systemd.targets;
    };
  in take (sane-lib.mkTypedMerge take configs);
}
