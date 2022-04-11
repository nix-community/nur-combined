{ nur
, wrapFirefox
, firefox-esr-91-unwrapped
, }:
wrapFirefox firefox-esr-91-unwrapped {
  desktopName = "Firefox (wrapped)";
  nixExtensions = with nur.repos.rycee.firefox-addons; [
    darkreader
    facebook-container
    grammarly
    i-dont-care-about-cookies
    localcdn
    sponsorblock
    tampermonkey
    ublock-origin
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
