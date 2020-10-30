{ config, lib, pkgs, ... }: {

  home.packages = with pkgs; [ gpa ];
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ "87F5686AC11C5D0AE1C7D66B7AE4D820B34CF744" ];
  };
}
