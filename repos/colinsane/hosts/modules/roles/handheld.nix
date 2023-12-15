{ config, lib, ... }:
{
  options.sane.roles.handheld = with lib; mkOption {
    type = types.bool;
    default = false;
    description = ''
      services/programs which you probably only want on a handheld device.
    '';
  };

  config = lib.mkIf config.sane.roles.handheld {
    sane.programs.guiApps.suggestedPrograms = [
      "consoleMediaUtils"  # overbroad, but handy on very rare occasion
      "handheldGuiApps"
    ];
  };
}

