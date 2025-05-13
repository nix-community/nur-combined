//! see also: the OpenInMPV browser extension
//! dev docs:
//! - chrome.contextMenus API: <https://developer.chrome.com/docs/extensions/reference/api/contextMenus>
//! - OnClickData: <https://developer.chrome.com/docs/extensions/reference/api/contextMenus#type-OnClickData>

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
    xdgOpen(tab.id, info.srcUrl || info.linkUrl || info.pageUrl);
  },
});
