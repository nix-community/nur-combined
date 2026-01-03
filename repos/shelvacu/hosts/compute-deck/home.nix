{ ... }:
{
  home-manager.users.shelvacu = {
    home.stateVersion = "23.11";
    programs.librewolf = {
      enable = true;

      settings = {
        # keep-sorted start
        "browser.shell.checkDefaultBrowser" = false;
        # I have never, literally never once, clicked "yes" on a geolocation request on a desktop/laptop
        "geo.enabled" = false;
        "network.cookie.lifetimePolicy" = 0;
        "privacy.clearOnShutdown.cookies" = false;
        "privacy.clearOnShutdown.history" = false;
        "privacy.resistFingerprinting" = false;
        "signon.prefillForms" = false;
        "signon.rememberSignons" = false;
        "webgl.disabled" = false;
        # keep-sorted end
      };
    };
  };
}
