{ pkgs, forceWayland ? false, extraExtensions ? [ ], ... }:
let
  wrapper = pkgs.wrapFirefox.override {
    fx_cast_bridge =
      let
        version = "0.1.0";
        pname = "fx_cast_bridge";
      in
      pkgs.fx_cast_bridge.overrideAttrs (_: {
        version = "0.1.0";
        src = pkgs.fetchurl {
          url = "https://github.com/hensm/fx_cast/releases/download/v${version}/${pname}-${version}-x64.deb";
          sha256 = "0hr7pf8vr154bjkzi4ys8zs8siipx4vb5r1n6cyjj2qili7l562n";
        };
      });
  };
in
wrapper pkgs.firefox-unwrapped {
  inherit forceWayland extraExtensions;
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
