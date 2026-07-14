{
  wrapFirefox,
  firefox-esr-unwrapped,
  widevine-firefox,
}:

let
  firefox-widevine = widevine-firefox;
in
(wrapFirefox firefox-esr-unwrapped {
  nameSuffix = "-esr";
  wmClass = "firefox-esr";
  icon = "firefox-esr";
  # https://github.com/nix-community/nixos-apple-silicon/issues/145#issuecomment-3441166112
  extraPrefs = ''
    lockPref("media.gmp-widevinecdm.version", "system-installed");
    lockPref("media.gmp-widevinecdm.visible", true);
    lockPref("media.gmp-widevinecdm.enabled", true);
    lockPref("media.gmp-widevinecdm.autoupdate", false);
    lockPref("media.eme.enabled", true);
    lockPref("media.eme.encrypted-media-encryption-scheme.enabled", true);
  '';
}).overrideAttrs
  # https://github.com/nix-community/nixos-apple-silicon/issues/145#issuecomment-3441166112
  (
    previousAttrs: {
      buildCommand = previousAttrs.buildCommand + ''
        wrapProgram "$oldExe" --set MOZ_GMP_PATH "${firefox-widevine}/gmp-widevinecdm/system-installed"
      '';
    }
  )
