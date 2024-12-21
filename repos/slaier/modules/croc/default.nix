{ pkgs, ... }:
{
  services.croc = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    croc
  ];
}
