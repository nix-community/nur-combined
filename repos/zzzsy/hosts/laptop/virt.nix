{ pkgs, ... }:
{
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    virt-manager
    virtiofsd
    #qemu
    #qemu_kvm
    #guestfs-tools
  ];
}
