const getDataSourceForDomain = (() => {
  const data = new Promise(res => {
    let port = browser.runtime.connect({ name: 'info-channel' });
    port.postMessage({
      type: 'fetchContentPack',
      url: window.location.toString()
    });

    port.onMessage.addListener(msg => {
      if (msg.type != 'fetchContentPackResult') return;
      if (msg.value != null)
        console.log("TETR.IO PLUS - TPSE pack preview mode", msg.value);
      res(msg.value);
    });
  })

  return async function getDataSourceForDomain() {
    if (await data) {
      return {
        async get(keys) {
          // Prevent infinite loops in some users that don't expect
          // the promise to resolve synchronously
          await new Promise(r => setTimeout(r));
          return await data; // It's technically complient
        }
      }
    } else {
      return browser.storage.local;
    }
  }
})();
