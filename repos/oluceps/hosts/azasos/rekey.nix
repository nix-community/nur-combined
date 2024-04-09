{ data, ... }:
{
  age = {
    identityPaths = [ "/var/lib/ssh/ssh_host_ed25519_key" ];
    rekey.hostPubkey = data.keys.azasosHostPubKey;
  };
}
