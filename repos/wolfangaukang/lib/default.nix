{ inputs
, lib
}:

let
  inherit (inputs) self;
  ips = lib.importJSON "${inputs.self}/misc/ips.json";

in
rec {
  mkNixos = import ./mkNixos.nix { inherit inputs mkNixosHome; };
  mkNixosHome = import ./mkNixosHome.nix { inherit inputs; };
  mkHome = import ./mkHome.nix { inherit inputs; };
  generateHyprlandMonitorConfig = info: hostname:
    let
      name = info.${hostname}.display.id;
      mode = info.${hostname}.display.mode;
      scale = info.${hostname}.display.scale;
    in "${name},${mode},0x0,${builtins.toString scale}";
  generateKanshiOutput = info: hostname: {
    criteria = info.${hostname}.display.id;
    mode = "${info.${hostname}.display.mode}Hz";
  };
  importSystemUsers = users: hostname: builtins.map (user: "${self}/system/users/${user}/hosts/${hostname}.nix") users;
  importHMUsers = users: hostname: builtins.listToAttrs (map (user: { name = user; value = import "${self}/home/users/${user}/hosts/${hostname}.nix"; }) users);
  obtainIPV4Address = hostname: network: "${ips.networking.networks.${network}}.${ips.networking.suffixes.${hostname}}";
  obtainIPV4GatewayAddress = network: suffix: "${ips.networking.networks.${network}}.${suffix}";
}
