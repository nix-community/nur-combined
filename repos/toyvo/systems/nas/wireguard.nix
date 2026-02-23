{
  config,
  ...
}:
let
  wireguardInterface = "wg0";
  wireguardInterfaceNamespace = "protonvpn0";
  wireguardGateway = "10.2.0.1";
in
{
  config = {
    sops.secrets."protonvpn-US-IL-503.key" = { };
    networking.wireguard.interfaces.${wireguardInterface} = {
      privateKeyFile = config.sops.secrets."protonvpn-US-IL-503.key".path;
      ips = [ "10.2.0.2/32" ];
      peers = [
        {
          publicKey = "Ad0UnBi3NeIgVpM1baC8HAp6wfSli0wGS1OCmS7uYRo=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "79.127.187.156:51820";
        }
      ];
      interfaceNamespace = wireguardInterfaceNamespace;
      preSetup = ''ip netns add "${wireguardInterfaceNamespace}"'';
      postSetup = ''
        ip -n "${wireguardInterfaceNamespace}" link set up dev "lo"
        ip -n "${wireguardInterfaceNamespace}" route add default dev "${wireguardInterface}"
      '';
      preShutdown = ''ip -n "${wireguardInterfaceNamespace}" route del default dev "${wireguardInterface}"'';
      postShutdown = ''ip netns del "${wireguardInterfaceNamespace}"'';
    };
    environment.etc."netns/${wireguardInterfaceNamespace}/resolv.conf".text =
      "nameserver ${wireguardGateway}";
  };
}
