{
  config,
  lib,
  ...
}:
let
  cfg = config.nixcfg.darwin.homebrew;
in
{
  options.nixcfg.darwin.homebrew.enable =
    lib.mkEnableOption "homebrew with default casks and activation settings";

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        upgrade = true;
      };
      casks = [
        {
          name = "firefox";
        }
        {
          name = "proton-drive";
        }
        {
          name = "protonvpn";
        }
      ];
    };
  };
}
