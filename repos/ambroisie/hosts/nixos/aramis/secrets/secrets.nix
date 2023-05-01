# Host-specific secrets
let
  keys = import ../../../../keys;

  all = [
    # This host is a laptop, it does not have a host key
    # Allow me to modify the secrets anywhere
    keys.users.ambroisie
  ];
in
{
  "wireguard/private-key.age".publicKeys = all;
}
