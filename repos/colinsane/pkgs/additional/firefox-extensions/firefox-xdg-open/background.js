//! largely copied from OpenInMPV browser extension

function xdgOpen(tabId, url) {
  const code = `
    var link = document.createElement('a')
    link.href='xdg-open:${url}'
    document.body.appendChild(link)
    link.click()`
  console.log(code)
  chrome.tabs.executeScript(tabId, { code })
}

[["page", "pageUrl"], ["link", "linkUrl"], ["video", "srcUrl"], ["audio", "srcUrl"]].forEach(([item, linkType]) => {
  chrome.contextMenus.create({
    title: "xdg-open",
    id: `open${item}inmpv`,
    contexts: [item],
    onclick: (info, tab) => {
      xdgOpen(tab.id, info[linkType]);
    },
  });
});
