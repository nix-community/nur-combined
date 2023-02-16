_: {
  fileSystems."/" = {
    device = "/dev/sda";
    fsType = "ext4";
  };

  swapDevices = [{ device = "/dev/sdb"; }];

  boot.kernelParams = [ "console=ttyS0,19200n8" ];
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial;
    terminal_output serial
  '';

  boot.loader.grub.forceInstall = true;
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;

  networking.usePredictableInterfaceNames = false;
  networking.interfaces.eth0.useDHCP = true;

  # If it's in the cloud, it's a server. We disable root SSH
  # and require strong factors for SSH auth already - make life
  # a little easier than managing unique passwords all over the 
  # device footprint
  security.sudo.wheelNeedsPassword = false;
}
