{ data, ... }:
let hostPrivKey = "/persist/keys/ssh_host_ed25519_key"; in {
  age.identityPaths = [ hostPrivKey ];
  age.rekey.hostPubkey = data.keys.hasturHostPubKey;
  services.openssh.hostKeys = [{
    path = hostPrivKey;
    type = "ed25519";
  }];
}

