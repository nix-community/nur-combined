# Common modules
{ lib, ... }:

{
  imports = [
    ./hardware
    ./home
    ./profiles
    ./programs
    ./secrets
    ./services
    ./system
  ];

  options.my = with lib; {
    user = {
      name = mkOption {
        type = types.str;
        default = "ambroisie";
        example = "alice";
        description = "my username";
      };

      home = {
        enable = my.mkDisableOption "home-manager configuration";
      };
    };
  };
}
