{
  config,
  lib,
  ...
}:
let
  cfg = config.nixcfg.darwin.terminfo;
in
{
  options.nixcfg.darwin.terminfo.enable = lib.mkEnableOption "terminfo directories including ghostty";

  config = lib.mkIf cfg.enable {
    environment.variables.TERMINFO_DIRS = lib.mkForce (
      map (path: path + "/share/terminfo") config.environment.profiles
      ++ [
        "/usr/share/terminfo"
        # Add ghostty terminfo from homebrew
        "/Applications/Ghostty.app/Contents/Resources/terminfo"
      ]
    );
  };
}
