createRewriteFilter("Touch control hooks", "https://tetr.io/js/tetrio.js*", {
  enabledFor: async (storage, request) => {
    let res = await storage.get('enableTouchControls');
    return res.enableTouchControls;
  },
  onStop: async (storage, url, src, callback) => {
    /*
      This patch exposes the game's key map as a global variable which is used
      to dispatch touch-to-key events with the correct bindings
    */
    let patched = false;
    let reg1 = /(\w{1,4})={controls:.{1,1000}?{moveLeft[^}]+}/;
    src = src.replace(reg1, (match, key) => {
      patched = true;
      return `____522=setTimeout(() => window.keyMap = ${key}),` + match;
    });
    if (!patched) console.log('Touch control hooks broke');

    callback({
      type: 'text/javascript',
      data: src,
      encoding: 'text'
    });
  }
})
