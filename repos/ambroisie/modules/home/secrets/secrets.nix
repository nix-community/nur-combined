# Common secrets
let
  keys = import ../../../keys;

  all = builtins.attrValues keys.users;
in
{
  "github/token.age".publicKeys = all;
}
