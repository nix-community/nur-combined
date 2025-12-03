{ config, ... }:
assert false; # this is a template
{
  vacu.databases.awesome-service-name = {
    # user = "awesome-service-name";
    fromContainer = "awesome-service-name";
  };

  vacu.proxiedServices.awesome-service-name = {
    domain = "awesome-service-name.shelvacu.com";
    fromContainer = "awesome-service-name";
    port = 80;
    forwardFor = true;
    maxConnections = 100;
  };

  containers.awesome-service-name = {
    privateNetwork = true;
    hostAddress = "192.168.100.something";
    localAddress = "192.168.100.something";

    autoStart = true;
    ephemeral = false;
    restartIfChanged = true;

    bindMounts."/awesome-service-name" = {
      hostPath = "/trip/awesome-service-name";
      isReadOnly = false;
    };

    config =
      { lib, ... }:
      {
        system.stateVersion = latest;

        networking.firewall.enable = false;
        networking.useHostResolvConf = lib.mkForce false;
        services.resolved.enable = true;
      };
  };
}
