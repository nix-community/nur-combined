{ ... }:
{
  sane.programs.rofi-kagi = {
    suggestedPrograms = [
      "rofi"
      "sane-open"
    ];

    sandbox.extraHomePaths = [
      ".config/mimeo"
      ".config/rofi"
      ".local/share/applications"  #< to locate .desktop files
    ];
    sandbox.whitelistPortal = [
      "OpenURI"
    ];
    sandbox.whitelistWayland = true;
  };
}
