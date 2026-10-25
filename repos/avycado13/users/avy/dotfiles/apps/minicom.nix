{ lib, config, ... }:
{
  options.dots.apps.minicom = {
    enable = lib.mkEnableOption "Enable minicom config";
    escapeKey = lib.mkOption {
      type = lib.types.enum [
        "^A"
        "^B"
        "Escape (Meta)"
        "Meta-8th bit"
      ];
      default = "^A";
      description = ''Minicom command prefix. "Escape (Meta)" makes it ESC-then-key.'';
    };
  };
  config = lib.mkIf config.dots.apps.minicom.enable {
    home.file.".minirc.dfl".text = ''
      pu mfcolor          WHITE
      pu mbcolor          BLACK
      pu tfcolor          WHITE
      pu tbcolor          BLACK
      pu sfcolor          BLACK
      pu sbcolor          GREEN
      pu histlines        5000
      pu statusline       enabled
      pu escape-key       ${config.dots.apps.minicom.escapeKey}
    '';

    # minicom paints the whole screen with an explicit SGR pair (\e[37;40m), so
    # any color choice means an opaque background. With color off it emits only
    # \e[0m and leans on reverse video, which keeps ghostty's transparency and
    # your palette. The colors above are what it uses if you flip this to on.
    home.sessionVariables.MINICOM = "-c off";
  };
}
