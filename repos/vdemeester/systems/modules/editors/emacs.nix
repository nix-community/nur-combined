{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.editors.emacs;
in
{
  options.modules.editors.emacs = {
    enable = mkEnableOption "enable emacs editor";
  };
  config = mkIf cfg.enable {
    # modules.editors.default = "emacs";
    # FIXME add a default configuration
    environment = {
      systemPackages = [ pkgs.emacs ];
      shellAliases = {
        e = "emacs";
      };
    };
  };
}
