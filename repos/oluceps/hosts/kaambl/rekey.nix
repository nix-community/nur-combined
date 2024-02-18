{ data, ... }:
let hostPrivKey = "/persist/keys/ssh_host_ed25519_key"; in {
  age = {
    identityPaths = [ hostPrivKey ];
    rekey.hostPubkey = data.keys.kaamblHostPubKey;
  };
  services.openssh.hostKeys = [{
    path = hostPrivKey;
    type = "ed25519";
  }];
}
