createRewriteFilter("OSD hooks", "https://tetr.io/js/tetrio.js*", {
  enabledFor: async (storage, request) => {
    let res = await storage.get('enableOSD');
    return res.enableOSD;
  },
  onStop: async (storage, url, src, callback) => {
    /*
      This patch emits a custom event when a new input handler is initialized
    */
    patched = false;
    let reg2 = /class [^{]+{\s*static\s*_EVENTKEYS((?!constructor)[\S\s])*constructor\([^)]+\)\s*{\s*super\([\w$]+\),/;
    src = src.replace(reg2, (match) => {
      patched = true;
      return match + `
        (() => {
          let that = this;
          setTimeout(() => {
            document.dispatchEvent(new CustomEvent('tetrio-plus-on-game', {
              detail: { instance: that }
            }));
          });
        })(),
      `;
    });
    if (!patched) console.log('OSD hooks filter broke');

    callback({
      type: 'text/javascript',
      data: src,
      encoding: 'text'
    });
  }
})
