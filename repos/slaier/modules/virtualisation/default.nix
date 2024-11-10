{ pkgs, ... }:
{
  virtualisation.virtualbox.host = {
    enable = true;
    headless = true;
  };
  environment.systemPackages = with pkgs; [
    vagrant
  ];
  environment.sessionVariables.VAGRANT_HOME = "~/.cache/.vagrant.d";
}
