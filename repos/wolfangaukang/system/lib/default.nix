{ inputs
,...
}:

let 
  inherit (inputs) self;
  common = import "${self}/system/hosts/common/settings.nix";

in {
  obtainIPV4Address = hostname: network: "${common.networking.networks.${network}}.${common.networking.suffixes.${hostname}}";
  obtainIPV4GatewayAddress = network: suffix: "${common.networking.networks.${network}}.${suffix}";
}
