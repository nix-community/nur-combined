{ config, ... }:
let
  hasVlans =
    if (builtins.length (builtins.attrNames config.networking.vlans) != 0) then
      true
    else
      false;
in {
  # useDHCP = false; 
  useDHCP = !hasVlans;
}
