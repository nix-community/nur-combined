{ config, pkgs, lib, ... }: {

  imports = [
    <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
    ../../profiles/nixos/console.nix
  ];

  # FIXME: Still testing
  virtualisation.qemu.options = [
   # "-vga none"
    "-device virtio-gpu-pci"
  ];
  #---------------------

  users.users.bjorn = {
    initialHashedPassword = "$6$y2Nhv2IH5i7hdlH.$P8GBuxWT.AILbsS6b3eUnGpUUaeAMjW4xyuAVbAdT8QcxxHAArEiZKvOIf9R7VD2O0I3tOoQZKFUonCc0wLIe.";
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ];
  };

  environment.systemPackages = with pkgs; [
    vim
  ];
  programs = {
    sway.enable = true;
    xwayland.enable = true;
  };
  services.xserver = {
    enable = false;
    logFile = "/tmp/xserver.log";
    layout = "us";
    xkbVariant = "colemak";
    #desktopManager.enlightenment.enable = true;
    #displayManager.ly = {
    #  enable = true;
    #  #defaultUser = "bjorn";
    #  extraConfig = ''
    #  lang = pt 
    #  asterisk = u 
    #  '';
    #};
  };

  system.stateVersion = "20.09";
}
