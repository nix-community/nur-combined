{ config, pkgs, ... }:
{
  sane.programs.geoclue-demo-agent = {
    packageUnwrapped = pkgs.linkFarm "geoclue-demo-agent" [{
      # bring the demo agent into a `bin/` directory so it can be invokable via PATH
      name = "bin/geoclue-demo-agent";
      path = "${config.sane.programs.geoclue2.packageUnwrapped}/libexec/geoclue-2.0/demos/agent";
    }];

    sandbox.whitelistDbus.system = true;

    services.geoclue-agent = {
      description = "geoclue 'demo' agent";
      # XXX: i don't actually understand how this works: upstream dbus rules would appear to restrict
      # the dbus owner to just root/geoclue, but we're neither and this still works (and breaks if i remove the agent service!)
      command = "geoclue-demo-agent";
      partOf = [ "graphical-session" ];
    };
  };
}
