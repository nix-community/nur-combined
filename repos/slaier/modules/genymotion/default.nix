{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    genymotion
  ];
  virtualisation.virtualbox = {
    host = {
      enable = true;
    };
    guest = {
      enable = true;
    };
  };
}
