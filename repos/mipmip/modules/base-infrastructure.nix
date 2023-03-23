{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    ansible
    terraform
    act # run github workflows locally
    notify # Notify allows sending the output from any tool to Slack, Discord and Telegram
    ssl-cert-check
  ];
}
