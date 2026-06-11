/*
*/
createRewriteFilter("Bootstrap.js hooks", "https://tetr.io/bootstrap.js*", {
  enabledFor: async (storage, url) => {
    let res = await storage.get([
      'bypassBootstrapper'
    ]);
    return res.bypassBootstrapper;
  },
  onStop: async (storage, url, src, callback) => {
    callback({
      type: 'text/javascript',
      data: `
        (() => {
          console.log('Bypassed bootstrap.js');
          let script = document.createElement('script');
          script.src = '/js/tetrio.js';
          document.head.appendChild(script);
        })();
      `,
      encoding: 'text'
    });
  }
})
