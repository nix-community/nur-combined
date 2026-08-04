{
  inputs,
  lib,
}:

let
  inherit (inputs) self;
  inherit (lib) importJSON;
  ips = importJSON "${self}/misc/ips.json";

in
{
  generateSopsAgeInfo = {
    # Using the persist drive path feels hacky, but /etc gets mounted/linked
    # after sops-nix is executed on boot.
    keyFile = "/mnt/persist/var/lib/sops-nix/keys.txt";
    sshKeyPaths = [ "/mnt/persist/etc/ssh/ssh_host_ed25519_key" ];
  };
  generateSshHostKeyPaths = [
    {
      bits = 4096;
      path = "/mnt/persist/etc/ssh/ssh_host_rsa_key";
      type = "rsa";
    }
    {
      path = "/mnt/persist/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
  getKanshiDisplays =
    let
      displays = importJSON "${self}/misc/displays.json";
    in
    builtins.mapAttrs (name: value: {
      criteria = value.id;
      mode = "${value.x}x${value.y}";
    }) displays;
  getNixFiles = path: profiles: map (profile: path + profile + ".nix") profiles;
  importSystemUsers =
    users: hostname: builtins.map (user: "${self}/system/users/${user}/hosts/${hostname}.nix") users;
  importHMUsers =
    users: hostname:
    builtins.listToAttrs (
      map (user: {
        name = user;
        value = import "${self}/home/users/${user}/hosts/${hostname}.nix";
      }) users
    );
  obtainIPV4Address =
    hostname: network: "${ips.networking.networks.${network}}.${ips.networking.suffixes.${hostname}}";
  obtainIPV4GatewayAddress = network: suffix: "${ips.networking.networks.${network}}.${suffix}";
}
