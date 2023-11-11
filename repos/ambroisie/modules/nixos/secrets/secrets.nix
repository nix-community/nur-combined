# Common secrets
let
  keys = import ../../keys;

  inherit (keys) all;
in
{
  "users/ambroisie/hashed-password.age".publicKeys = all;
  "users/root/hashed-password.age".publicKeys = all;
}
