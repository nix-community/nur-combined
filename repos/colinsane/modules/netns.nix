{ config, lib, pkgs, sane-lib, ... }:
let
  cfg = config.sane.netns;
  netnsOpts = with lib; types.submodule {
    options = {
      dns = mkOption {
        type = types.str;
        default = "1.1.1.1";  #< TODO: make the default be to forward DNS queries to the init namespace.
      };
      hostVethIpv4 = mkOption {
        type = types.str;
      };
      netnsVethIpv4 = mkOption {
        type = types.str;
      };
      netnsPubIpv4 = mkOption {
        type = types.str;
      };
      routeTable = mkOption {
        type = types.int;
        description = ''
          numeric ID for iproute2 (0-255?).
          each netns gets its own routing table so that i can route a packet out by placing it in the table.
        '';
      };
    };
  };
  mkNetNsConfig = name: opts: with opts; {
    systemd.services."netns-${name}" = let
      ip = lib.getExe' pkgs.iproute2 "ip";
      iptables = lib.getExe' pkgs.iptables "iptables";
      in-ns = "${ip} netns exec ${name}";
      bridgePort = port: proto: ''
        ${in-ns} ${iptables} -A PREROUTING -t nat -p ${proto} --dport ${port} -m iprange --dst-range ${netnsPubIpv4} \
          -j DNAT --to-destination ${hostVethIpv4}
      '';
      bridgeStatements = lib.foldlAttrs
        (acc: port: portCfg: acc ++ (builtins.map (bridgePort port) portCfg.protocol))
        []
        (lib.filterAttrs
          (port: portCfg: portCfg.visibleTo."${name}")
          config.sane.ports.ports
        )
      ;
    in {
      description = "create a network namespace which will selectively bridge traffic with the init namespace";
      # specifically, we need to set these up before wireguard-wg-*,
      wantedBy = [ "network-pre.target" ];
      before = [ "network-pre.target" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = ''
        ${ip} netns add ${name} || (test -e /run/netns/${name} && echo "${name} already exists")
        # DOCS:
        # - some of this approach is described here: <https://josephmuia.ca/2018-05-16-net-namespaces-veth-nat/>
        # - iptables primer: <https://danielmiessler.com/study/iptables/>
        # create veth pair
        ${ip} link add ${name}-veth-a type veth peer name ${name}-veth-b || echo "${name}-veth-{a,b} aleady exists"
        ${ip} addr add ${hostVethIpv4}/24 dev ${name}-veth-a || echo "${name}-veth-a aleady has IP address"
        ${ip} link set ${name}-veth-a up

        # move veth-b into the namespace
        ${ip} link set ${name}-veth-b netns ${name} || echo "${name}-veth-b was already moved into its netns"
        ${in-ns} ${ip} addr add ${netnsVethIpv4}/24 dev ${name}-veth-b || echo "${name}-veth-b aleady has IP address"
        ${in-ns} ${ip} link set ${name}-veth-b up

        # make it so traffic originating from the host side of the veth
        # is sent over the veth no matter its destination.
        ${ip} rule add from ${hostVethIpv4} lookup ${name} pref 50 || echo "${name} already has ip rules (pref 50)"

        # for traffic originating at the host veth to the WAN, use the veth as our gateway
        # not sure if the metric 1002 matters.
        ${ip} route add default via ${netnsVethIpv4} dev ${name}-veth-a proto kernel src ${hostVethIpv4} metric 1002 table ${name} || \
          echo "${name} already has default route"
        # give the default route lower priority
        ${ip} rule add from all lookup local pref 100 || echo "${name}: already has ip rules (pref 100)"
        ${ip} rule del from all lookup local pref 0 || echo "${name}: already removed ip rule of default lookup (pref 0)"

        # in order to access DNS in this netns, we need to route it to the VPN's nameservers
        # - alternatively, we could fix DNS servers like 1.1.1.1.
        ${in-ns} ${iptables} -A OUTPUT -t nat -p udp --dport 53 -m iprange --dst-range 127.0.0.53 \
          -j DNAT --to-destination ${dns}:53
      '' + (lib.concatStringsSep "\n" bridgeStatements);
      preStop = ''
        ${in-ns} ${ip} link del ${name}-veth-b || echo "couldn't delete ${name}-veth-b"
        ${ip} link del ${name}-veth-a || echo "couldn't delete ${name}-veth-a"
        ${ip} netns delete ${name} || echo "couldn't delete ${name}"
        # restore rules/routes
        ${ip} rule del from ${hostVethIpv4} lookup ${name} pref 50 || echo "couldn't delete init -> ${name} rule"
        ${ip} route del default via ${netnsVethIpv4} dev ${name}-veth-a proto kernel src ${hostVethIpv4} metric 1002 table ${name} || echo "couldn't delete init > ${name} route"
        # FIXME: if there are other net namespaces active, changing the prefs here may break those!
        ${ip} rule add from all lookup local pref 0
        ${ip} rule del from all lookup local pref 100
      '';
    };

    # for some reason network-pre doesn't actually get run before network.target by default??
    systemd.targets.network-pre.wantedBy = [ "network.target" ];
    systemd.targets.network-pre.before = [ "network.target" ];

    # create a new routing table that we can use to proxy traffic out of the root namespace
    # through the wireguard namespaces, and to the WAN via VPN.
    # i think the numbers here aren't particularly important.
    networking.iproute2.rttablesExtraConfig = ''
      ${builtins.toString routeTable} ${name}
    '';
    networking.iproute2.enable = true;
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
    configs = lib.mapAttrsToList mkNetNsConfig cfg;
    take = f: {
      networking.localCommands = f.networking.localCommands;
      networking.iproute2.rttablesExtraConfig = f.networking.iproute2.rttablesExtraConfig;
      networking.iproute2.enable = f.networking.iproute2.enable;
      systemd.services = f.systemd.services;
      systemd.targets.network-pre = f.systemd.targets.network-pre;
    };
  in take (sane-lib.mkTypedMerge take configs);
}
