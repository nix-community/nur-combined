{ user, data, ... }:
let hostPrivKey = "/persist/keys/ssh_host_ed25519_key"; in {
  age = {
    identityPaths = [ hostPrivKey ];
    rekey.hostPubkey = data.keys.hasturHostPubKey;
    secrets = {
      nextchat = { rekeyFile = ../../sec/nextchat.age; mode = "400"; owner = "root"; group = "users"; name = "nextchat"; };
      addr-map = { rekeyFile = ../../sec/addr-map.age; mode = "640"; owner = user; group = "root"; name = "addr-map"; };
      prom = { rekeyFile = ../../sec/prom.age; mode = "640"; owner = "prometheus"; group = "users"; };
    };
  };
  services.openssh.hostKeys = [{
    path = hostPrivKey;
    type = "ed25519";
  }];
}

