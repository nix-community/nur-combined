{ config, pkgs, ... }: {
  services.lorri.enable = true;
  environment.systemPackages = with pkgs; [ direnv ];
}
