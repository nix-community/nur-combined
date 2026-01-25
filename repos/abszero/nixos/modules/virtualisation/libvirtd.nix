{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    const
    genAttrs
    ;
  cfg = config.abszero.virtualisation.libvirtd;
in

{
  options.abszero.virtualisation.libvirtd.enable = mkEnableOption "libvirtd";

  config = mkIf cfg.enable {
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
      };
      spiceUSBRedirection.enable = true;
    };
    users.users = genAttrs config.abszero.users.admins (const {
      extraGroups = [ "libvirtd" ];
    });
    programs.virt-manager.enable = true;
    environment.systemPackages = with pkgs; [ virtio-win ];
  };
}
