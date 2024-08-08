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
        ovmf = {
          enable = true;
          packages = with pkgs; [ OVMFFull.fd ];
        };
        swtpm.enable = true;
      };
    };
  };
}
