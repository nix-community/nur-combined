{ data, ... }:
{
  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    rekey.hostPubkey = data.keys.colourHostPubKey;

    secrets = {
      prom = {
        rekeyFile = ../../sec/prom.age;
        mode = "640";
        owner = "prometheus";
        group = "users";
      };

      wgc-warp = {
        rekeyFile = ../../sec/wgc-warp.age;
        owner = "systemd-network";
        group = "root";
        mode = "400";
      };

    };
  };
}
