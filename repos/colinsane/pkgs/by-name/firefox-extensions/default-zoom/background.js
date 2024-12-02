// simplified implementation of <https://github.com/jamielinux/default-zoom>

console.info("[default-zoom]", "background.js: initializing");

// XXX(2024-12-01): this implementation works for any tabs loaded with ctrl+t, and ctrl+l.
// it works for the homepage too, except for a first-run edge case wherein the homepage is loaded
// before any extensions are loaded
//
// considerations:
// - desko: fed.uninsane.org is most comfortable 1.8 - 2.4
// - desko: github.com is most comfortable 1.5 - 2.0
// - desko: youtube.com is most comfortable 1.6 - 1.8
// - desko: wikipedia.org is most comfortable 1.7 - 1.9
// - lappy: amazon.com is most comfortable 1.0 - 1.2
let defaultZoom = 1;

// retrieving settings:
// - <https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/storage>
// - manifest.json requires `permissions = [ "storage" ]`
// - retrieve with `browser.storage.{backend}.get(...)`
//   - e.g. <https://github.com/mdn/webextensions-examples/blob/main/stored-credentials/storage.js>
function applyConfig(storedConfig) {
  console.info("[default-zoom]", "applyConfig");
  if (storedConfig && storedConfig.zoom) {
    console.info("[default-zoom]", "applyConfig -> zoom", storedConfig.zoom);
    defaultZoom = storedConfig.zoom;
  }
}

function onConfigError(error) {
  console.info("[default-zoom]", "onConfigError");
  console.error(error);
}

function setZoom(tabId, changeInfo) {
  console.info("[default-zoom]", "setZoom");
  if (changeInfo.status) {
    console.info("[default-zoom]", "setZoom -> changeInfo.status exists");
    const gettingZoom = browser.tabs.getZoom(tabId);
    gettingZoom.then((currentZoom) => {
      console.info("[default-zoom]", "setZoom -> tabs.getZoom complete");
      if (defaultZoom !== 1 && currentZoom === 1) {
        console.info("[default-zoom]", "setZoom -> tabs.setZoom", defaultZoom);
        browser.tabs.setZoom(tabId, defaultZoom);
      }
    });
  }
}

browser.storage.managed.get("zoom").then(applyConfig, onConfigError);

browser.tabs.onUpdated.addListener(setZoom);
browser.tabs.onCreated.addListener((tab) => {
  browser.tabs.setZoom(tab.id, defaultZoom);
});

console.info("[default-zoom]", "background.js: initialized");
