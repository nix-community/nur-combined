/**
 * @param {string} name
 * @param {string} url
 * @param {Object} options
 * @param {Function<DataSource, Filter, boolean>} options.enabledFor
 * @param {Function<DataSource, Request, Filter, string?>} options.onStart
 * @param {Function<DataSource, Request, Filter, string?>} options.onStop
 */
function createRewriteFilter(name, url, options) {
  browser.webRequest.onBeforeRequest.addListener(
    async request => {
      if (new URL(request.url).searchParams.get('bypass-tetrio-plus') != null) {
        console.log(`[${name} filter] Ignoring bypassed ${url}`);
        return;
      }

      let origin = request.originUrl || request.url;
      console.log("Request origin URL", origin);
      const dataSource = await getDataSourceForDomain(origin);

      let { tetrioPlusEnabled } = await dataSource.get('tetrioPlusEnabled');
      if (!tetrioPlusEnabled) {
        console.log(`[${name} filter] TETR.IO PLUS disabled, ignoring ${url}`);
        return;
      }

      if (options.enabledFor) {
        let enabled = await options.enabledFor(dataSource, request.url);
        if (!enabled) {
          console.log(`[${name} filter] Disabled, ignoring ${url}`);
          return;
        }
      }

      if (options.blockRequest) {
        request.cancel = true;
        console.log(`[${name} filter] Request to ${url} blocked`);
        return;
      }

      console.log(`[${name} filter] Filtering ${url}`);

      if (options.onStart || options.onStop) {
        let filter = browser.webRequest.filterResponseData(request.requestId);
        
        function callback({ type, data, encoding }) {
          switch(encoding || 'text') {
            case 'base64-data-url':
              filter.write(convertDataURIToBinary(data));
              break;
            case 'text':
              filter.write(new TextEncoder().encode(data));
              break;
            case 'arraybuffer':
              filter.write(data);
              break;
            default:
              throw new Error('Unknown encoding');
          }
        }

        if (options.onStart) {
          filter.onstart = async evt => {
            await options.onStart(dataSource, request.url, null, callback);
            // Close the filter now if there's no onStop handler to close it.
            if (!options.onStop)
              filter.close();
          }
        }

        if (options.onStop) {
          // Potential future BUG: We're assuming onStop will only be called
          // with textual data, but in the future we might want to process binary
          // data in transit.
          let originalData = [];
          let decoder = new TextDecoder("utf-8");
          filter.ondata = event => {
            let str = decoder.decode(event.data, { stream: true });
            originalData.push(str);
          }
          filter.onstop = async evt => {
            await options.onStop(dataSource, request.url, originalData.join(''), callback);
            filter.close();
          }
        }
      }
    },
    { urls: [url] },
    ["blocking"]
  )
}

// https://gist.github.com/borismus/1032746
var BASE64_MARKER = ';base64,';
function convertDataURIToBinary(dataURI) {
  var base64Index = dataURI.indexOf(BASE64_MARKER) + BASE64_MARKER.length;
  var base64 = dataURI.substring(base64Index);
  return Uint8Array.fromBase64(base64);
}
