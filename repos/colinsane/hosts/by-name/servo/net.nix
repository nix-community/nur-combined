{ config, lib, pkgs, ... }:

let
  portOpts = with lib; types.submodule {
    options = {
      visibleTo.ovpns = mkOption {
        type = types.bool;
        default = false;
        description = ''
          whether to forward inbound traffic on the OVPN vpn port to the corresponding localhost port.
        '';
      };
      visibleTo.doof = mkOption {
        type = types.bool;
        default = false;
        description = ''
          whether to forward inbound traffic on the doofnet vpn port to the corresponding localhost port.
        '';
      };
    };
  };
in
{
  options = with lib; {
    sane.ports.ports = mkOption {
      # add the `visibleTo.{doof,ovpns}` options
      type = types.attrsOf portOpts;
    };
  };

  config = {
    networking.domain = "uninsane.org";

    sane.ports.openFirewall = true;
    sane.ports.openUpnp = true;

    # unless we add interface-specific settings for each VPN, we have to define nameservers globally.
    # networking.nameservers = [
    #   "1.1.1.1"
    #   "9.9.9.9"
    # ];

    # services.resolved.extraConfig = ''
    #   # docs: `man resolved.conf`
    #   # DNS servers to use via the `wg-ovpns` interface.
    #   #   i hope that from the root ns, these aren't visible.
    #   DNS=46.227.67.134%wg-ovpns 192.165.9.158%wg-ovpns
    #   FallbackDNS=1.1.1.1 9.9.9.9
    # '';

    # tun-sea config
    sane.dns.zones."uninsane.org".inet.A."doof.tunnel" = "205.201.63.12";
    # sane.dns.zones."uninsane.org".inet.AAAA."doof.tunnel" = "2602:fce8:106::51";  #< TODO: enable IPv6
    networking.wireguard.interfaces.wg-doof = {
      privateKeyFile = config.sops.secrets.wg_doof_privkey.path;
      # wg is active only in this namespace.
      # run e.g. ip netns exec doof <some command like ping/curl/etc, it'll go through wg>
      #   sudo ip netns exec doof ping www.google.com
      interfaceNamespace = "doof";
      ips = [
        "205.201.63.12"
        # "2602:fce8:106::51/128"  #< TODO: enable IPv6
      ];
      peers = [
        {
          publicKey = "nuESyYEJ3YU0hTZZgAd7iHBz1ytWBVM5PjEL1VEoTkU=";
          # TODO: configure DNS within the doof ns and use tun-sea.doof.net endpoint
          # endpoint = "tun-sea.doof.net:53263";
          endpoint = "205.201.63.44:53263";
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
          persistentKeepalive = 25; #< keep the NAT alive
        }
      ];
    };
    sane.netns.doof.hostVethIpv4 = "10.0.2.5";
    sane.netns.doof.netnsVethIpv4 = "10.0.2.6";
    sane.netns.doof.netnsPubIpv4 = "205.201.63.12";
    sane.netns.doof.routeTable = 12;

    # OVPN CONFIG (https://www.ovpn.com):
    # DOCS: https://nixos.wiki/wiki/WireGuard
    # if you `systemctl restart wireguard-wg-ovpns`, make sure to also restart any other services in `NetworkNamespacePath = .../ovpns`.
    # TODO: why not create the namespace as a seperate operation (nix config for that?)
    networking.wireguard.enable = true;
    networking.wireguard.interfaces.wg-ovpns = {
      privateKeyFile = config.sops.secrets.wg_ovpns_privkey.path;
      # wg is active only in this namespace.
      # run e.g. ip netns exec ovpns <some command like ping/curl/etc, it'll go through wg>
      #   sudo ip netns exec ovpns ping www.google.com
      interfaceNamespace = "ovpns";
      ips = [ "185.157.162.178" ];
      peers = [
        {
          publicKey = "SkkEZDCBde22KTs/Hc7FWvDBfdOCQA4YtBEuC3n5KGs=";
          endpoint = "185.157.162.10:9930";
          # alternatively: use hostname, but that presents bootstrapping issues (e.g. if host net flakes)
          # endpoint = "vpn36.prd.amsterdam.ovpn.com:9930";
          allowedIPs = [ "0.0.0.0/0" ];
          # nixOS says this is important for keeping NATs active
          persistentKeepalive = 25;
          # re-executes wg this often. docs hint that this might help wg notice DNS/hostname changes.
          # so, maybe that helps if we specify endpoint as a domain name
          # dynamicEndpointRefreshSeconds = 30;
          # when refresh fails, try it again after this period instead.
          # TODO: not avail until nixpkgs upgrade
          # dynamicEndpointRefreshRestartSeconds = 5;
        }
      ];
    };
    sane.netns.ovpns.hostVethIpv4 = "10.0.1.5";
    sane.netns.ovpns.netnsVethIpv4 = "10.0.1.6";
    sane.netns.ovpns.netnsPubIpv4 = "185.157.162.178";
    sane.netns.ovpns.routeTable = 11;
    sane.netns.ovpns.dns = "46.227.67.134";  #< DNS requests inside the namespace are forwarded here
  };
}
