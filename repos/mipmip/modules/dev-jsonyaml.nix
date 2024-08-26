{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [

    nickel
    yamllint
    sq # Swiss army knife for data
    jq
    yj
    dasel
    jsonnet

  ];
}
