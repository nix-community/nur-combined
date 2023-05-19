{ config, lib, pkgs, materusPkgs, ... }:
let 
cfg = config.materus.profile.browser;
in
{
  
  options= let mkBoolOpt = materusPkgs.lib.mkBoolOpt; in{
    materus.profile.browser.firefox.enable = mkBoolOpt config.materus.profile.enableDesktop "Enable Firefox with materus cfg";
    materus.profile.browser.vivaldi.enable = mkBoolOpt false "Enable Vivaldi with materus cfg";

  };
  #TODO: Make some config
  config.home.packages = [
  (lib.mkIf cfg.firefox.enable config.materus.profile.packages.firefox)
  (lib.mkIf cfg.vivaldi.enable pkgs.vivaldi)
  ];
  

}