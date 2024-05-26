{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ open-sans ];
}
