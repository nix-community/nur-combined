(async () => {
  if (window.location.pathname != '/') return;
  let storage = await getDataSourceForDomain(window.location);
  let opts = await storage.get([
    'tetrioPlusEnabled', 'enableOSD', 'useOldOSDIcons'
  ]);
  if (!opts.tetrioPlusEnabled || !opts.enableOSD) return;

  let script = document.createElement('script');
  script.src = browser.runtime.getURL("source/injected/osd.js");
  document.head.appendChild(script);

  window.addEventListener("getBaseIconURL", function dispatchConfig() {
    let iconSet = opts.useOldOSDIcons ? 'old' : 'new';
    window.dispatchEvent(new CustomEvent("baseIconURL", {
      detail: JSON.stringify({
        iconSet: iconSet,
        baseIconURL: browser.runtime.getURL(`resources/osd/${iconSet}/`)
      })
    }));
  }, false);
})().catch(console.error);
