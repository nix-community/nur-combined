{ vaculib, pkgs, ... }: {
  imports = vaculib.directoryGrabberList ./.;
  vacu.hostName = "ripper";
  vacu.shortHostName = "rip";
  vacu.systemKind = "desktop";
  vacu.isDev = false;
  vacu.isMinimal = true;

  services.openssh.enable = true;

  system.stateVersion = "25.11";

  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  services.pipewire.enable = false; # uses a bunch of cpu randomly and i don't need audio

  vacu.packages = ''
    solaar
    gomtree
  '';

  services.udev.packages = [ pkgs.logitech-udev-rules ];
}
