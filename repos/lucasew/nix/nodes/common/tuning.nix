{pkgs, ...}:
{
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
    tmp.cleanOnBoot = true;
  };
  services = {
    irqbalance.enable = true;
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
    };
  };
}
