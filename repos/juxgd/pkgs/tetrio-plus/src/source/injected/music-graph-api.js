(() => {
  const prefix = append => 'tetrio-plus-music-graph-api-' + append;
  let nonceIncr = 0;
  function makeAPICall(name, ...args) {
    return new Promise((resolve, reject) => {
      let nonce = ++nonceIncr;

      document.addEventListener(prefix(`${name}-response-${nonce}`), evt => {
        let { ok, result, error } = JSON.parse(evt.detail);
        if (!ok) return reject(error);
        resolve(result);
      }, { once: true });

      document.dispatchEvent(new CustomEvent(prefix(name), {
        detail: { nonce, arguments: args }
      }));
    });
  }

  window.tetrioPlus = {
    musicGraph: {
      getActiveNodes: makeAPICall.bind(null, 'getActiveNodes'),
      dispatchEvent: makeAPICall.bind(null, 'dispatchEvent'),
      setF8DebuggerEnabled: makeAPICall.bind(null, 'setF8DebuggerEnabled')
    }
  };
})();
