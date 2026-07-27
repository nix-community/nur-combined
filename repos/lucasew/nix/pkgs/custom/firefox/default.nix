{
  nbr,
  lib,
  wrapFirefox,
  firefox-esr-unwrapped,
  fetchFirefoxAddon,
  callPackage,
}:
wrapFirefox firefox-esr-unwrapped {
  desktopName = "Firefox (wrapped)";
  applicationName = "firefox";
  # life is too short to compile firefox every bump lol
  # nixExtensions =
  #   (with nbr.firefoxExtensions; [
  #     darkreader
  #     facebook-container
  #     languagetool
  #     i-dont-care-about-cookies
  #     sponsorblock
  #     tampermonkey
  #     ublock-origin
  #     tweak-new-twitter
  #     floccus
  #     video-downloadhelper
  #   ])
  #   ++ ([ (callPackage ./base16-ext { }) ]);
  extraPolicies = {
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DisableTelemetry = true;
    OfferToSaveLogins = false;
    PasswordManagerEnabled = false;
    UserMessaging = {
      ExtensionRecommendations = false;
      SkipOnboarding = true;
    };
  };
}
