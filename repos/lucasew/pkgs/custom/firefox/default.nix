{ nur
, lib
, wrapFirefox
, stable
, firefox-esr-102-unwrapped
, fetchFirefoxAddon
, firefox-bin
, callPackage
, }:
wrapFirefox firefox-esr-102-unwrapped {
  desktopName = "Firefox (wrapped)";
  applicationName = "firefox";
  nixExtensions = let
    ryceeExtensions = with nur.repos.rycee.firefox-addons;[
      darkreader
      facebook-container
      grammarly
      i-dont-care-about-cookies
      sponsorblock
      tampermonkey
      ublock-origin
      xbrowsersync
    ];
  in  []
  ++ (map (e: fetchFirefoxAddon {
      inherit (e) name;
      url = builtins.elemAt e.src.urls 0;
      sha256 = e.src.outputHash;
    }) ryceeExtensions)
  ++ (map fetchFirefoxAddon [
    {
      name = "tweak-new-twitter";
      url = "https://addons.mozilla.org/firefox/downloads/file/3927389/tweak_new_twitter-2.15.0.xpi";
      sha256 = "sha256-0PwcclKg27Q1Dur/BUUHBXNbCo3MnX8sZRfTqjQXP+Y=";
    }
  ]
  ++ ([
    (callPackage ./base16-ext {})
  ]))
  ;
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

