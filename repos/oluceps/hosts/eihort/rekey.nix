{ data, ... }:
{
  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    rekey.hostPubkey = data.keys.eihortHostPubKey;

    secrets = {
      # hyst-az-cli-eih = { rekeyFile = ../../sec/hyst-az-cli-eih.age; mode = "640"; owner = "root"; group = "users"; name = "hyst-az-cli-eih"; };
      hyst-az-cli-has = { rekeyFile = ../../sec/hyst-az-cli-has.age; mode = "640"; owner = "root"; group = "users"; name = "hyst-az-cli-has.yaml"; };
    };
  };
}
