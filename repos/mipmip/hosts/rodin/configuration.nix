{ config, inputs, system, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../_roles/desktop.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  virtualisation.libvirtd.enable = true;

#  virtualisation.qemu.networkingOptions = [
##  virtualisation.qemu.options = [
##
##      # Better display option
##      "-vga virtio"
##      "-display gtk,zoom-to-fit=false"
##      # Enable copy/paste
##      # https://www.kraxel.org/blog/2021/05/qemu-cut-paste/
##      "-chardev qemu-vdagent,id=ch1,name=vdagent,clipboard=on"
##      "-device virtio-serial-pci"
##      "-device virtserialport,chardev=ch1,id=ch1,name=com.redhat.spice.0"
#    "hostfwd=tcp::2222-:22:"
#    "-netdev tap,id=net0,br=virbr0,helper=$(type -p qemu-bridge-helper)"
#  ];
#

  services.flatpak.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  networking.hostName = "rodin";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  system.stateVersion = "22.11";
}
