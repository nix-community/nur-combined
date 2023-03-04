{ config, lib, pkgs, ... }:
with lib;
{
  options.networking = {
    enableNftablesFullcone = mkEnableOption "Nftables Fullcone NAT";
  };
  config = mkIf config.networking.enableNftablesFullcone {
    boot.extraModulePackages = [
      (pkgs.nft-fullcone.override {
        inherit (config.boot.kernelPackages) kernel;
      })
    ];
    nixpkgs.overlays = [
      (final: prev: {
        nftables = final.nftables-fullcone;
      })
    ];
  };
}
