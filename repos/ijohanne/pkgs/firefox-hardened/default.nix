{ pkgs, forceWayland ? false, extraExtension ? [ ], ... }:
let
  wrapper = pkgs.wrapFirefox.override { fx_cast_bridge = pkgs.fx_cast_bridge; };
in
wrapper pkgs.firefox-unwrapped {
  inherit forceWayland;
  extraExtensions = extraExtension;
  extraPolicies = {
    CaptivePortal = false;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DisableTelemetry = true;
    DisableFirefoxAccounts = true;
    FirefoxHome = {
      Pocket = false;
      Snippets = false;
    };
    UserMessaging = {
      ExtensionRecommendations = false;
      SkipOnboarding = true;
    };
  };
  extraPrefs = ''
    // Show more ssl cert infos
    lockPref("security.identityblock.show_extended_validation", true);
    // Enable userchrome css
    lockPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
    // Enable dark dev tools
    lockPref("devtools.theme","dark");
    // Misc other settings
    lockPref("extensions.autoDisableScopes", 0);
    lockPref("browser.uidensity", 1);
    lockPref("browser.search.openintab", true);
    lockPref("extensions.update.enabled", false);
    lockPref("identity.fxaccounts.enabled", false);
    lockPref("signon.rememberSignons", false);
    lockPref("signon.rememberSignons.visibilityToggle", false);
    lockPref("media.eme.enabled", true);
    lockPref("browser.eme.ui.enabled", true);
  '';
}
