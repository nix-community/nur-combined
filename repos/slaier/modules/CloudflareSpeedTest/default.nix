{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    CloudflareSpeedTest
  ];
}
