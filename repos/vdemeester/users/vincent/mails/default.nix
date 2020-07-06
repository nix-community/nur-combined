{ hostname, pkgs, ... }:
let
  sync = (hostname == "wakasu");
in
{
  imports = [ ../../modules ];
  profiles.mails = {
    enable = true;
    sync = sync;
  };
  home.file.".gmailctl/config.jsonnet".source = ./config.jsonnet;

  xdg.configFile."nr/mails" = {
    text = builtins.toJSON [
      { cmd = "gmailctl"; chan = "unstable"; }
    ];
    onChange = "${pkgs.my.nr}/bin/nr mails";
  };
}
