//! see also: the OpenInMPV browser extension
//! dev docs:
//! - chrome.contextMenus API: <https://developer.chrome.com/docs/extensions/reference/api/contextMenus>
//! - OnClickData: <https://developer.chrome.com/docs/extensions/reference/api/contextMenus#type-OnClickData>
//!
//! HOW TO DEBUG:
//! 1. launch firefox
//! 2. F12 to open console
//! 3. click on the gear icon
//! 4. select "Persist Logs"
//! 5. right click on something & click 'xdg-open'
//! 6. console should log "Navigated to xdg-open:..."

function xdgOpen(tabId, url) {
  const code = `
    var link = document.createElement('a')
    link.href='xdg-open:${url}'
    document.body.appendChild(link)
    link.click()`
  console.log(code)
  chrome.tabs.executeScript(tabId, { code })
}

chrome.contextMenus.create({
  title: "xdg-open",
  id: "xdg-open",
  contexts: ["audio", "link", "page", "video"],
  onclick: (info /*: OnClickData*/, tab /*: Tab*/) => {
    /* XXX(2025-12-12): the first call to xdg-open-scheme-handler within a
     * firefox process lifetime fails for unknown reasons. seems to be a bug
     * with firefox -- not the xdg-open-scheme-handler or xdg-open.
     *
     * hack around this bug by calling xdg-open-scheme-handler twice for each
     * user action. the first call is `xdg-open-scheme-handler xdg-open:null`;
     * a no-op action for which we don't care whether firefox does or does not
     * execute. the second call exercises the full xdg-open route for the
     * requested resource, and by merit of it not being the first `xdg-open:`
     * scheme for this process, we expect that it will *always* be delivered --
     * regardless if this is the 1st, or nth, user request for a xdg-open: resource */
    xdgOpen(tab.id, "null");
    xdgOpen(tab.id, info.srcUrl || info.linkUrl || info.pageUrl);
  },
});
