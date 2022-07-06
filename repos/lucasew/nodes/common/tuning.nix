{...}:
{
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
    cleanTmpDir = true;
  };
  services = {
    irqbalance.enable = true;
    ananicy.enable = true;
  };
}
