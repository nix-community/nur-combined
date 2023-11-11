# Extra wireguard keys that are not hosts NixOS hosts
let
  keys = import ../../../../keys;

  all = [
    keys.users.ambroisie
  ];
in
{
  # Sarah's iPhone
  "milady/private-key.age".publicKeys = all;

  # My Android phone
  "richelieu/private-key.age".publicKeys = all;
}
