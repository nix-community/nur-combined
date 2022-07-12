{
  mozSupportedApps = {
    firefox = {
      fullName = "Firefox";
      addonIdSuffix = "firefox.mozilla.org";
      extensionDir = "{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";
    };
    thunderbird = {
      fullName = "Thunderbird";
      addonIdSuffix = "thunderbird.mozilla.org";
      extensionDir = "{3550f703-e582-4d05-9a08-453d09bdfdc6}";
    };
  };

  mozPlatforms = {
    i686-linux = "linux-i686";
    x86_64-linux = "linux-x86_64";
  };

  mozLangpackSources = builtins.fromJSON (builtins.readFile ./sources.json);
}
