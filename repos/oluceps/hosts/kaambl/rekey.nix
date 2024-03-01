{ data, ... }:
let hostPrivKey = "/persist/keys/ssh_host_ed25519_key"; in {
  age = {
    identityPaths = [ hostPrivKey ];
    rekey.hostPubkey = data.keys.kaamblHostPubKey;
    secrets = {
      hyst-az-cli-kam = { rekeyFile = ../../sec/hyst-az-cli-kam.age; mode = "640"; owner = "root"; group = "users"; name = "hyst-az-cli-kam.yaml"; };
    };
  };
  services.openssh.hostKeys = [{
    path = hostPrivKey;
    type = "ed25519";
  }];
}
