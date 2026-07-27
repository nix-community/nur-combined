{ config, lib, pkgs, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.core.boot;
in
{
  options = {
    core.boot.systemd-boot = mkOption {
      description = "Enable systemd-boot for loading";
      # This is meant to be disable only on a few cases (qemu images, DigitalOcean droplets, …)
      default = true;
      type = types.bool;
    };
  };
  config = {
    boot.loader.systemd-boot.enable = cfg.systemd-boot;
  };
}
