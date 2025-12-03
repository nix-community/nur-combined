{ ... }:
{
  home-manager.users.shelvacu = {
    home.stateVersion = "23.11";
    programs.librewolf = {
      enable = true;

      settings = {
        "webgl.disabled" = false;
        "privacy.resistFingerprinting" = false;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "network.cookie.lifetimePolicy" = 0;
        "browser.shell.checkDefaultBrowser" = false;
        "signon.rememberSignons" = false;
        "signon.prefillForms" = false;
        # I have never, literally never once, clicked "yes" on a geolocation request on a desktop/laptop
        "geo.enabled" = false;
      };
    };
  };
}
