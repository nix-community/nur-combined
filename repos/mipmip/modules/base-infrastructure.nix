{ config, lib, pkgs, pkgs-2211, ... }:

{
  environment.systemPackages = with pkgs; [

    #    ansible
    pkgs-2211.terraform
    act # run github workflows locally
    notify # Notify allows sending the output from any tool to Slack, Discord and Telegram
    ssl-cert-check
  ];
}
