{ data, ... }:
{
  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    rekey.hostPubkey = data.keys.yidhraHostPubKey;
    secrets = {
      # wgy = {
      #   rekeyFile = ../../sec/wgy.age;
      #   owner = "systemd-network";
      #   group = "root";
      #   mode = "400";
      # };
    };
  };
}
