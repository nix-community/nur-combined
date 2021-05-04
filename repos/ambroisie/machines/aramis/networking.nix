{ ... }:
{
  networking = {
    hostName = "aramis";
    domain = "nodomain.local"; # FIXME: gotta fix domain handling
    wireless.enable = true;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;

    interfaces = {
      enp0s31f6.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };
  };

  # Which interface is used to connect to the internet
  my.networking.externalInterface = "enp0s3";
}
