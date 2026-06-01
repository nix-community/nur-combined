{
  config,
  lib,
  ...
}:
let
  cfg = config.nixcfg.darwin.keyboard;
in
{
  options.nixcfg.darwin.keyboard.enable =
    lib.mkEnableOption "keyboard remapping (caps lock to control)";

  config = lib.mkIf cfg.enable {
    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
