# Common modules
{ lib, ... }:

{
  imports = [
    ./hardware
    ./home.nix
    ./services
    ./system
  ];

  options.my = with lib; {
    username = mkOption {
      type = types.str;
      default = "ambroisie";
      example = "alice";
      description = "my username";
    };
  };
}
