{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (pkgs) fetchurl;
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.dotdrop;

  dotdropFishComp = fetchurl {
    url = "https://raw.githubusercontent.com/deadc0de6/dotdrop/master/completion/dotdrop.fish";
    hash = "sha256-msoL+TmqNJl3i4QGFPEnmSK1OsMhpBNWe4BDVihhQw4=";
  };
in

{
  options.abszero.programs.dotdrop.enable = mkEnableOption "dotfiles manager";

  config = mkIf cfg.enable {
    home.shellAliases = {
      dotdrop = "~/src/dotfiles/scripts/dotdrop.sh";
      dotsync = "~/src/dotfiles/scripts/dotsync.sh";
      sysdrop = "~/src/sysfiles/scripts/dotdrop.sh";
      syssync = "~/src/sysfiles/scripts/dotsync.sh";
    };
    xdg.configFile."fish/completions/dotdrop.fish".source = dotdropFishComp;
  };
}
