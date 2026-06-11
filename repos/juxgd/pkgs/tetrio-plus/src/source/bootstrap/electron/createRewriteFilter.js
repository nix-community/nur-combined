// global rewriteHandlers defined in electron-main.js

function matchesGlob(glob, string) {
  return new RegExp(
    '^' +
    glob
      .split('*')
      .map(seg => seg.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'))
      .join('.*') +
    '$'
  ).test(string);
}

electronMainWindow.webContents.session.webRequest.onBeforeRequest(
  { urls: ['https://tetr.io/*', '*://*.adinplay.com/*', '*://adinplay.com/*'] },
  (request, callback) => {
    if (new URL(request.url).searchParams.get('bypass-tetrio-plus') != null) {
      greenlog(`[prefilter] Ignoring bypassed ${request.url}`);
      callback({});
      return;
    }
    (async () => {
      // greenlog("Request origin URL", request);

      let origin = request.referrer;
      const dataSource = await getDataSourceForDomain(origin);

      let { tetrioPlusEnabled } = await dataSource.get('tetrioPlusEnabled');
      if (!tetrioPlusEnabled) {
        greenlog(`[prefilter] TETR.IO PLUS disabled, ignoring ${url}`);
        return;
      }

      // greenlog('Data source for origin', origin, Object.keys(dataSource));
      // greenlog(`onBeforeRequest: Considering ${request.url}...`);

      // FIXME:
      // Temporary stopgap until I find a decent workaround to the whole
      // service worker issue
      if (/sw.js\/?$/.test(request.url)) {
        greenlog("Blocked service worker.")
        callback({ cancel: true });
        return;
      }

      for (let { name, url, options } of rewriteHandlers) {
        if (!matchesGlob(url, request.url)) continue;

        if (options.enabledFor) {
          let enabled = await options.enabledFor(dataSource, request.url);
          if (!enabled) {
            greenlog(`[${name} filter] Disabled, ignoring ${request.url}`);
            continue;
          }
        }

        if (options.blockRequest) {
          greenlog(`[${name} filter] Request to ${url} \u001b[31mblocked`);
          callback({ cancel: true });
          return;
        }

        greenlog(`[${name} filter] Redirecting ${request.url}`);
        let relative = request.url.substring('https://tetr.io/'.length);

        let { useContentPack } = new URL(origin)
          .search
          .slice(1)
          .split('&')
          .map(e => e.split('='))
          .reduce((obj, [key, value]) => {
            obj[key] = value;
            return obj;
          }, {});
        if (useContentPack)
          relative += '?useContentPack=' + useContentPack;

        // handled in electron-main
        callback({ redirectURL: 'tetrio-plus://tetrio-plus/' + relative });
        return;
      }

      callback({});
    })().catch(ex => {
      greenlog("createRewriteFilter error: ", ex);
      callback({});
    })
  }
)

function createRewriteFilter(name, url, options) {
  greenlog("[Sandboxed] createRewriteFilter", name, url, Object.keys(options));
  rewriteHandlers.push({ name, url, options });
}
