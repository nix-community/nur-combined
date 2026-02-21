# based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/firefox/mobile-config.nix
{
  runCommand,
  fetchFromGitLab,
  wrapFirefox,
  firefox-esr-unwrapped,
  callPackage,
  widevine-firefox,
}:

let
  firefox-widevine = widevine-firefox;
  pkg = fetchFromGitLab {
    domain = "gitlab.postmarketos.org";
    owner = "postmarketOS";
    repo = "mobile-config-firefox";
    rev = "4.6.0";
    hash = "sha256-tISfxN/04spgtKStkkn+zlCtFU6GbtwuZubqpGN2olA=";
  };
  mobileConfigDir = runCommand "mobile-config-firefox" { } ''
    mkdir -p $out/mobile-config-firefox/{common,userChrome,userContent}

    cp ${pkg}/src/common/*.css $out/mobile-config-firefox/common/
    cp ${pkg}/src/userChrome/*.css $out/mobile-config-firefox/userChrome/
    cp ${pkg}/src/userContent/*.css $out/mobile-config-firefox/userContent/

    (cd $out/mobile-config-firefox && find common -name "*.css" | sort) >> $out/mobile-config-firefox/userChrome.files
    (cd $out/mobile-config-firefox && find common -name "*.css" | sort) >> $out/mobile-config-firefox/userContent.files

    (cd $out/mobile-config-firefox && find userChrome -name "*.css" | sort) > $out/mobile-config-firefox/userChrome.files
    (cd $out/mobile-config-firefox && find userContent -name "*.css" | sort) > $out/mobile-config-firefox/userContent.files

  '';

  mobileConfigAutoconfig = runCommand "mobile-config-autoconfig.js" { } ''
    substitute ${pkg}/src/mobile-config-autoconfig.js $out \
      --replace "/etc/mobile-config-firefox" "${mobileConfigDir}/mobile-config-firefox"
  '';

  mobileConfigPrefs = runCommand "mobile-config-prefs.js" { } ''
    # Remove the autoconfig setup lines since we handle that through extraPrefsFiles
    grep -v "general.config.filename" ${pkg}/src/mobile-config-prefs.js | \
    grep -v "general.config.obscure_value" | \
    grep -v "general.config.sandbox_enabled" > $out
  '';
in
(wrapFirefox firefox-esr-unwrapped {
  nameSuffix = "-esr";
  wmClass = "firefox-esr";
  icon = "firefox-esr";
  extraPrefsFiles = [
    mobileConfigAutoconfig
    mobileConfigPrefs
  ];

  # https://github.com/nix-community/nixos-apple-silicon/issues/145#issuecomment-3441166112
  extraPrefs = ''
    lockPref("media.gmp-widevinecdm.version", "system-installed");
    lockPref("media.gmp-widevinecdm.visible", true);
    lockPref("media.gmp-widevinecdm.enabled", true);
    lockPref("media.gmp-widevinecdm.autoupdate", false);
    lockPref("media.eme.enabled", true);
    lockPref("media.eme.encrypted-media-encryption-scheme.enabled", true);
  '';

  extraPoliciesFiles = [
    "${pkg}/src/policies.json"
  ];
}).overrideAttrs
  # https://github.com/nix-community/nixos-apple-silicon/issues/145#issuecomment-3441166112
  (
    previousAttrs: {
      buildCommand = previousAttrs.buildCommand + ''
        wrapProgram "$oldExe" --set MOZ_GMP_PATH "${firefox-widevine}/gmp-widevinecdm/system-installed"
      '';
    }
  )
