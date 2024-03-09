# Networking configuration
{ ... }:

{
  networking = {
    hostName = "porthos"; # Define your hostname.
    domain = "belanyi.fr"; # Define your domain.

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    useDHCP = true;
    interfaces = {
      eno1.useDHCP = true;
      eno2.useDHCP = true;
    };
  };

  # Which interface is used to connect to the internet
  my.hardware.networking.externalInterface = "eno1";
}
