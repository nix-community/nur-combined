(async () => {
  if (window.location.pathname != '/') return;
  let storage = await getDataSourceForDomain(window.location);
  let opts = await storage.get(['tetrioPlusEnabled', 'enableReplaySaver']);
  if (!opts.tetrioPlusEnabled || !opts.enableReplaySaver) return;
  console.log("[TETR.IO PLUS DEBUG] Replay saver activated");

  let script = document.createElement('script');
  script.src = browser.runtime.getURL("source/injected/replay-saver.js");
  document.head.appendChild(script);

  window.addEventListener('tetrio-plus-intercepted-replay', evt => {
    console.log("Received tetrio-plus-intercepted-replay", evt);
    try {
      JSON.parse(evt.detail);
    } catch(ex) {
      console.error(`Replay isn't valid JSON? Refusing to save.`);
      return;
    }

    let port = browser.runtime.connect({ name: 'info-channel' });
    port.postMessage({ type: 'saveReplay', replay: evt.detail });
  });
})().catch(console.error);
