{ data, ... }:
let hostPrivKey = "/persist/keys/ssh_host_ed25519_key"; in {
  age = {
    identityPaths = [ hostPrivKey ];
    rekey.hostPubkey = data.keys.hasturHostPubKey;
    secrets = {
      hyst-us-cli-has = { rekeyFile = ../../sec/hyst-us-cli-has.age; mode = "640"; owner = "root"; group = "users"; name = "hyst-us-cli-has.yaml"; };
      hyst-az-cli-has = { rekeyFile = ../../sec/hyst-az-cli-has.age; mode = "640"; owner = "root"; group = "users"; name = "hyst-az-cli-has.yaml"; };
    };
  };
  services.openssh.hostKeys = [{
    path = hostPrivKey;
    type = "ed25519";
  }];
}

