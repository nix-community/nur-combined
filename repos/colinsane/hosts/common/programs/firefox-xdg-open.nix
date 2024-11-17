{ pkgs, ... }:
{
  sane.programs.firefox-xdg-open = {
    packageUnwrapped = pkgs.firefox-extensions.firefox-xdg-open.systemComponent;

    sandbox.whitelistDbus = [ "user" ];  # for xdg-open/portals

    mime.associations."x-scheme-handler/xdg-open" = "xdg-open.desktop";

    suggestedPrograms = [ "xdg-utils" ];
  };
}
