{ ... }:
{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "enp5s0";
    enableIPv6 = true;
  };
}
