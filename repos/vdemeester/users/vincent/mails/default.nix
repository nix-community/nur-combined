{ hostname, pkgs, ... }:
let
  sync = (hostname == "aomi");
in
{
  imports = [ ../../modules ];
  profiles.mails = {
    enable = true;
    sync = sync;
  };
  home.file.".gmailctl/config.jsonnet".source = ./config.jsonnet;
  home.file.".gmailctl/gmailctl.libsonnet".source = ./gmailctl.libsonnet;
  home.packages = with pkgs; [ gmailctl ];
}
