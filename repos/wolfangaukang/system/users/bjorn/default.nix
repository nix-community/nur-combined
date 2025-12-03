{
  pkgs,
  lib,
  config,
  ...
}:

{
  programs.fish.enable = true;
  users.users.bjorn = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "nixers"
    ]
    ++ lib.optionals config.networking.networkmanager.enable [ "networkmanager" ]
    ++ lib.optionals config.programs.adb.enable [ "adbusers" ]
    ++ lib.optionals config.hardware.i2c.enable [ "i2c" ];
  };
}
