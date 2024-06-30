{ config, lib, ... }:

with lib;

{
  options = {
    home.disableMacPowerButton = mkOption
      {
        type = with types; nullOr bool;
        default = null;
        example = literalExpression "true";
      };
  };
  config = {
    home.activation.disableMacPowerButton =
      let
        disablePowerRaw = config.home.disableMacPowerButton;
        disableScreenLockImmediate = if disablePowerRaw != null then lib.hm.booleans.yesNo config.home.disableMacPowerButton else null;
      in
      (mkIf (disableScreenLockImmediate != null) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Disable/enable power button.
        echo "setting up power button..." >&2

        run defaults write com.apple.loginwindow DisableScreenLockImmediate -bool ${disableScreenLockImmediate}
      ''));
  };
}
