{ inputs
, ...
}:

{
  imports = [ "${inputs.self}/home/users/nixos" ];
}
