{ localFlake, withSystem }:
{
  config,
  lib,
  ...
}:

let
  cfg = config.boot.tcp-brutal;

in
{
  options.boot.tcp-brutal = {
    enable = lib.mkEnableOption "TCP Brutal is Hysteria's congestion control algorithm ported to TCP, as a Linux kernel module.";
  };

  config = lib.mkIf cfg.enable {
    assertions = [ ];

    boot.extraModulePackages = [
      (config.boot.kernelPackages.callPackage "${localFlake}/_pkgs/tcp-brutal.nix" { })
    ];
    boot.kernelModules = [ "brutal" ];
  };
}
