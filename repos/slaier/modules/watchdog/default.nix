{
  boot.kernel.sysctl = {
    "kernel.panic" = 10;
    "kernel.softlockup_panic" = 1;
  };
  services.watchdogd.enable = true;
}
