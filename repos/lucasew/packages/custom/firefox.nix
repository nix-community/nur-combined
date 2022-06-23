{ nur
, wrapFirefox
, stable
, firefox-esr-91-unwrapped
, fetchFirefoxAddon
, firefox-bin
, }:
wrapFirefox firefox-esr-91-unwrapped {
  desktopName = "Firefox (wrapped)";
  applicationName = "firefox";
  nixExtensions = with nur.repos.rycee.firefox-addons; map (e: fetchFirefoxAddon {
    inherit (e) name;
    url = builtins.elemAt e.src.urls 0;
    sha256 = e.src.outputHash;
  }) [
    darkreader
    facebook-container
    grammarly
    i-dont-care-about-cookies
    sponsorblock
    tampermonkey
    ublock-origin
    xbrowsersync
  ];
  extraPolicies = {
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DisableTelemetry = true;
    UserMessaging = {
      ExtensionRecommendations = false;
      SkipOnboarding = true;
    };
  };
}

