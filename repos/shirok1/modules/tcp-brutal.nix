{ localFlake, withSystem }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkOption
    mkEnableOption
    types
    mkIf
    optionalAttrs
    optionals
    ;

  cfg = config.services.tcp-brutal;

in
{
  options.services.tcp-brutal = {
    enable = mkEnableOption "TCP Brutal is Hysteria's congestion control algorithm ported to TCP, as a Linux kernel module.";
  };

  config = lib.mkIf cfg.enable {
    assertions = [ ];

    boot.extraModulePackages = [
      (config.boot.kernelPackages.callPackage "${localFlake}/_pkgs/tcp-brutal.nix" { })
    ];
  };
}
