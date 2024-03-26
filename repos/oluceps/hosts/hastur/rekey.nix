{ data, ... }:
let hostPrivKey = "/persist/keys/ssh_host_ed25519_key"; in {
  age = {
    identityPaths = [ hostPrivKey ];
    rekey.hostPubkey = data.keys.hasturHostPubKey;
    secrets = {
      nextchat = { rekeyFile = ../../sec/nextchat.age; mode = "400"; owner = "root"; group = "users"; name = "nextchat"; };
    };
  };
  services.openssh.hostKeys = [{
    path = hostPrivKey;
    type = "ed25519";
  }];
}

