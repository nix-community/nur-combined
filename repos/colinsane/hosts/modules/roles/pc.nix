{ config, lib, ... }:
{
  options.sane.roles.pc = with lib; mkOption {
    type = types.bool;
    default = false;
    description = ''
      programs/services which only make sense for a PC form factor (e.g. keyboard + mouse).
    '';
  };

  config = lib.mkIf config.sane.roles.pc {
    sane.programs.guiApps.suggestedPrograms = [
      "pcGuiApps"
    ];
    sane.programs.gameApps.suggestedPrograms = [
      "pcGameApps"
    ];
    sane.programs.consoleUtils.suggestedPrograms = [
      "consoleMediaUtils"
      "pcConsoleUtils"
    ];
  };
}
