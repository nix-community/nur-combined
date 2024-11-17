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
    sane.programs.geoclue2.suggestedPrograms = [
      "gps-share"
    ];
    sane.programs.sway.suggestedPrograms = [
      "sane-input-handler"
    ];

    sane.programs.alacritty.config.fontSize = 9;

    sane.programs.firefox.config = {
      # compromise impermanence for the sake of usability
      persistCache = "private";
      persistData = "private";

      # i don't do crypto stuff on moby
      addons.ether-metamask.enable = false;
      # sidebery UX doesn't make sense on small screen
      addons.sidebery.enable = false;
    };
    sane.programs.firefox.mime.priority = 300;  # prefer other browsers when possible
    # HACK/TODO: make `programs.P.env.VAR` behave according to `mime.priority`
    sane.programs.firefox.env = lib.mkForce {};
    sane.programs.epiphany.env.BROWSER = "epiphany";

    sane.programs.sway.config = {
      font = "pango:monospace 10";
      locker = "schlock";
      mod = "Mod1";  # prefer Alt
      workspace_layout = "tabbed";
    };

    sane.programs.swayidle.config = {
      actions.screenoff.delay = 300;
      actions.screenoff.enable = true;
    };
    sane.programs.swaynotificationcenter.config = {
      enableMpris = false;  #< consumes too much screen real-estate
    };

    sane.programs.waybar.config = {
      fontSize = 14;
      height = 26;
      persistWorkspaces = [ "1" "2" "3" "4" "5" ];
      modules.media = false;
      modules.network = false;
      modules.perf = false;
      modules.windowTitle = false;
      # TODO: show modem state
    };
    sane.programs.nwg-panel.config = {
      fontSize = 14;
      height = 26;
      windowIcon = false;
      windowTitle = false;
      mediaPrevNext = false;
      mediaTitle = false;
      sysload = false;
      workspaceNumbers = [ "1" "2" "3" "4" "5" ];
      workspaceHideEmpty = false;
    };

    sane.programs.sane-deadlines.config.showOnLogin = false;  # unlikely to act on them when in shell
  };
}

