{ buildMozillaXpiAddon, lib }:
let
  # Not listed on AMO, so mozilla-addons-to-nix cannot fetch it. The signed
  # xpi is published in the GitHub releases instead; media-harvest.json is
  # bumped by .github/workflows/update.yml
  source = lib.importJSON ./media-harvest.json;
  addonId = "mediaharvest@mediaharvest.app";
in
buildMozillaXpiAddon {
  pname = "media-harvest";
  inherit (source) version sha256;
  inherit addonId;
  url = "https://github.com/EltonChou/TwitterMediaHarvest/releases/download/v${source.version}/${addonId}-v${source.version}.xpi";
  meta = with lib; {
    homepage = "https://github.com/EltonChou/TwitterMediaHarvest";
    description = "Download videos and images from twitter or TweetDeck with only one click.";
    license = licenses.mpl20;
    mozPermissions = [
      "downloads"
      "cookies"
      "storage"
      "notifications"
      "unlimitedStorage"
      "alarms"
      "*://twitter.com/*"
      "*://mobile.twitter.com/*"
      "*://api.twitter.com/*"
      "*://tweetdeck.twitter.com/*"
      "*://x.com/*"
      "*://*.x.com/*"
    ];
    platforms = platforms.all;
  };
}
