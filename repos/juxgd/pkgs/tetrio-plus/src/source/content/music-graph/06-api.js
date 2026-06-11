musicGraph(musicGraph => {
  let { graph, nodes, dispatchEvent, cleanup } = musicGraph;
  let script = document.createElement('script');
  script.src = browser.runtime.getURL('source/injected/music-graph-api.js');
  document.head.appendChild(script);

  const prefix = append => 'tetrio-plus-music-graph-api-' + append;
  function createAPICall(name, validators, handler) {
    let controller = new AbortController();
    cleanup.push(() => controller.abort());
    document.addEventListener(prefix(name), evt => {
      let response = null;
      let nonce = evt.detail.nonce;
      let args = evt.detail.arguments;

      try {
        if (!nonce || !Array.isArray(args))
          throw new Error('Nonce or arguments missing');

        if (args.length != validators.length)
          throw new Error('Invalid number of arguments');

        for (let i = 0; i < args.length; i++) {
          if (typeof validators[i] == 'string')
            if (typeof args[i] != validators[i])
              throw new Error(`Argument #${i+1}: expected ${validators[i]}`);
          if (typeof validators[i] == 'function') {
            let res = validators[i](args[i]);
            if (res === false)
              throw new Error(`Argument #${i+1} invalid`);
          }
        }

        response = { ok: true, result: handler(...args) };
      } catch(ex) {
        response = { ok: false, error: ex.toString() };
      }

      document.dispatchEvent(new CustomEvent(prefix(`${name}-response-${nonce}`), {
        detail: JSON.stringify(response)
      }));
    }, { signal: controller.signal });
  }

  createAPICall(
    'dispatchEvent',
    [ 'string', arg => arg == null || typeof arg == 'string' || typeof arg == 'number' ],
    (name, value) => { dispatchEvent(name, value); }
  );

  createAPICall(
    'getActiveNodes',
    [],
    () => nodes.map(node => ({
      id: node.id,
      source: node.source,
      variables: node.variables,
      time: node.currentTime
    }))
  );

  createAPICall(
    'setF8DebuggerEnabled',
    ['boolean'],
    (enabled) => musicGraph.f8menuEnabled = enabled
  );
});
