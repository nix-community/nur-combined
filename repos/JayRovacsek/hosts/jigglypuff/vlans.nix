{ config, ... }:
let
  name = "dns";
  interface = "eth0";
  id = 6;
in {
  networking.vlans.${name} = { inherit interface id; };
  networking.interfaces.${name}.useDHCP = true;
}
