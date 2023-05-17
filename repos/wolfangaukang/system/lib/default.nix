{ inputs
,...
}:

let
  inherit (inputs) self;
  ips = import "${self}/system/hosts/common/settings/ip.nix";

in {
  obtainIPV4Address = hostname: network: "${ips.networking.networks.${network}}.${ips.networking.suffixes.${hostname}}";
  obtainIPV4GatewayAddress = network: suffix: "${ips.networking.networks.${network}}.${suffix}";
}
