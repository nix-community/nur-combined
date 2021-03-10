{pkgs, ...}:
with import ../../globalConfig.nix;
{
  imports = [
    ../bootstrap/default.nix
    ../../modules/cloudflared/system.nix
    ../../modules/cachix/system.nix
    ../../modules/randomtube/system.nix
    ../../modules/vercel-ddns/system.nix
  ];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 30;
  };
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 20;
    };
    cleanTmpDir = true;
  };
  environment.variables.EDITOR = "nvim";
  services = {
    irqbalance.enable = true;
  };
  cachix.enable = true;
}
