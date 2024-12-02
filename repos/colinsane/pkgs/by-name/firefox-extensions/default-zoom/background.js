// simplified implementation of <https://github.com/jamielinux/default-zoom>
//
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
let defaultZoom = 1.7;

function setZoom(tabId, changeInfo) {
  if (changeInfo.status) {
    const gettingZoom = browser.tabs.getZoom(tabId);
    gettingZoom.then((currentZoom) => {
      if (defaultZoom !== 1 && currentZoom === 1) {
        browser.tabs.setZoom(tabId, defaultZoom);
      }
    });
  }
}

browser.tabs.onCreated.addListener((tab) => {
  browser.tabs.setZoom(tab.id, defaultZoom);
});

browser.tabs.onUpdated.addListener(setZoom);
