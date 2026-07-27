{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
{
  options.eownerdead.libvirtd = mkEnableOption ''
    Enable libvirtd.
  '';

  config = mkIf config.eownerdead.libvirtd {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        vhostUserPackages = with pkgs; [ virtiofsd ];
      };
      nss = {
        enable = true;
        enableGuest = true;
      };
    };
  };
}
