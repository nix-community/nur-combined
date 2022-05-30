{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    ungoogled-chromium
  ];


}
