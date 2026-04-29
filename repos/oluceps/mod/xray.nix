{
  flake.modules.nixos.xray =
    { lib, config, ... }:
    {
      options.xray.configFile = lib.mkOption {
        type = lib.types.str;
      };
      config = {

        systemd.services.xray.restartIfChanged = false;
        services.xray = {
          enable = true;
          settingsFile = config.xray.configFile;
        };
      };
    };
}
