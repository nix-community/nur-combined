{ firefox-addons }:

{
  firefox = {
    settings = {
      "browser.download.dir" = "/home/bjorn/Elsxutujo";
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.tabs.warnOnClose" = false;
      "extensions.pocket.enabled" = false;
      "privacy.donottrackheader.enabled" = true;
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;
    };
    search = {
      force = true;
      default = "DuckDuckGo";
    };
    extensions = with firefox-addons; [
      auto-tab-discard
      decentraleyes
      disable-javascript
      privacy-badger
      ublock-origin
      # 1: Following guide from EFF and dephasing the extension usage
      # https://www.eff.org/https-everywhere/set-https-default-your-browser
      #https-everywhere
    ];
  };
}
