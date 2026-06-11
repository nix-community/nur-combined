browser.runtime.onInstalled.addListener(evt => {
  migrate(browser.storage.local);
})
