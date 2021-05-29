# Networking configuration
{ ... }:

{
  networking = {
    hostName = "porthos"; # Define your hostname.
    domain = "belanyi.fr"; # Define your domain.


    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;

    interfaces = {
      bond0.useDHCP = true;
      bonding_masters.useDHCP = true;
      dummy0.useDHCP = true;
      erspan0.useDHCP = true;
      eth0.useDHCP = true;
      eth1.useDHCP = true;
      gre0.useDHCP = true;
      gretap0.useDHCP = true;
      ifb0.useDHCP = true;
      ifb1.useDHCP = true;
      ip6tnl0.useDHCP = true;
      sit0.useDHCP = true;
      teql0.useDHCP = true;
      tunl0.useDHCP = true;
    };
  };

  # Which interface is used to connect to the internet
  my.hardware.networking.externalInterface = "eth0";
}
