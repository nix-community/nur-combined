{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.essential;
in
{
  options.essential = {
    enable = mkEnableOption "Essential tools";
  };

  config = mkIf cfg.enable {
    programs.bat.enable = true;
    programs.eza.enable = true;
    programs.fd.enable = true;
    programs.fzf.enable = true;
    programs.htop.enable = true;
    programs.micro.enable = true;
    programs.ripgrep.enable = true;
  };
}
