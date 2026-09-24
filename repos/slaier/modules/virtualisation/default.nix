{ pkgs, ... }:
{
  virtualisation = {
    virtualbox = {
      host = {
        enable = true;
        enableHardening = false;
      };
    };
  };
  environment.systemPackages = with pkgs; [
    vagrant
  ];
}
