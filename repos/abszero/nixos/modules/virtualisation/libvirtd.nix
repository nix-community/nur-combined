{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.virtualisation.libvirtd;
in

{
  options.abszero.virtualisation.libvirtd.enable = mkEnableOption "libvirtd";

  config = mkIf cfg.enable {
    virtualisation = {
      libvirtd.enable = true;
      spiceUSBRedirection.enable = true;
    };
    programs.virt-manager.enable = true;
    environment.systemPackages = with pkgs; [ virtio-win virtiofsd ];
  };
}
