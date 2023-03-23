{ config, lib, pkgs, unstable, ... }:

{

  environment.systemPackages = with pkgs; [

    mipmip_pkg.cryptobox
    cryptsetup

    keepassxc
    bitwarden

  ];
}

