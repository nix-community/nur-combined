{
  config,
  global,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.virtualisation.libvirtd.enable {
    users.users.${global.username} = {
      extraGroups = [
        "kvm"
        "libvirtd"
      ];
    };
    # Host CPU only — no cross-arch system emulators
    virtualisation.libvirtd.qemu.package = lib.mkDefault pkgs.qemu_kvm;
    systemd.services.libvirtd.path = with pkgs; [ virtiofsd ];
  };
}
