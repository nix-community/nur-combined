{ inputs
, lib
}:

let
  inherit (inputs) self;
  ips = lib.importJSON "${self}/misc/ips.json";
  host_defaults = lib.importJSON "${self}/system/hosts/common/host_defaults.json";

in
rec {
  mkNixos = import ./mkNixos.nix { inherit inputs mkNixosHome; };
  mkNixosHome = import ./mkNixosHome.nix { inherit inputs; };
  mkHome = import ./mkHome.nix { inherit inputs; };
  generateHyprlandMonitorConfig = info:
    let
      name = info.display.id;
      mode = info.display.mode;
      scale = info.display.scale;
    in "${name},${mode},0x0,${builtins.toString scale}";
  generateKanshiOutput = info: {
    criteria = info.display.id;
    mode = "${info.display.mode}Hz";
  };
  getHostDefaults = host: host_defaults.${host};
  importSystemUsers = users: hostname: builtins.map (user: "${self}/system/users/${user}/hosts/${hostname}.nix") users;
  importHMUsers = users: hostname: builtins.listToAttrs (map (user: { name = user; value = import "${self}/home/users/${user}/hosts/${hostname}.nix"; }) users);
  obtainIPV4Address = hostname: network: "${ips.networking.networks.${network}}.${ips.networking.suffixes.${hostname}}";
  obtainIPV4GatewayAddress = network: suffix: "${ips.networking.networks.${network}}.${suffix}";
}
