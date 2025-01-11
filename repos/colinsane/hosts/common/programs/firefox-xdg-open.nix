{ pkgs, ... }:
{
  sane.programs.firefox-xdg-open = {
    packageUnwrapped = pkgs.firefox-extensions.firefox-xdg-open.systemComponent;

    sandbox.whitelistPortal = [
      "OpenURI"
    ];

    mime.associations."x-scheme-handler/xdg-open" = "xdg-open.desktop";

    suggestedPrograms = [ "xdg-utils" ];
  };
}
