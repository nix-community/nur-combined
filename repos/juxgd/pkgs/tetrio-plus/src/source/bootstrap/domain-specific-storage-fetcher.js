/*
  This file exposes a helper function and a cache for safely retrieving
  a content pack from a given url. It provides both objects/null and
  wrappers/fallback.
*/

async function domainDataStatus(urlString) {
  let {
    allowURLPackLoader,
    whitelistedLoaderDomains,
    tetrioPlusEnabled
  } = await browser.storage.local.get([
    'allowURLPackLoader',
    'whitelistedLoaderDomains',
    'tetrioPlusEnabled'
  ]);

  if (!tetrioPlusEnabled)
    return { ok: false, reason: 'TETR.IO PLUS is disabled' };

  if (urlString === '')
    return { ok: false, reason: 'URL does not specify a content pack (is empty string)' };
  
  try {
    var { useContentPack } = new URL(decodeURI(urlString))
      .search
      .slice(1)
      .split('&')
      .map(e => e.split('='))
      .reduce((obj, [key, value]) => {
        obj[key] = value;
        return obj;
      }, {});
  } catch(ex) {
    console.trace("failed to decode url", urlString, ex);
    return { ok: false, reason: 'invalid URL: ' + ex };
  }
  
  if (!useContentPack)
    return { ok: false, reason: 'URL does not specify a content pack' };

  if (!allowURLPackLoader)
    return { ok: false, reason: 'URL pack loading is disabled' };

  let url = new URL(decodeURIComponent(useContentPack));

  if (whitelistedLoaderDomains.indexOf(url.origin) == -1)
    return { ok: false, reason: 'Domain ' + url.origin + ' not whitelisted' };

  return { ok: true, url: url };
}

const REQUEST_CACHE = {};
async function getDataForDomain(urlString) {
  try {
    let { ok, reason, url } = await domainDataStatus(urlString);
    if (!ok) return null;

    if (!REQUEST_CACHE[url]) {
      REQUEST_CACHE[url] = (async () => {
        let req = await fetch(url, { mode: 'cors' });
        let unsanitizedData = await req.json();

        let sanitizedData = {};
        let result = await sanitizeAndLoadTPSE(unsanitizedData, {
          async set(pairs) {
            Object.assign(sanitizedData, pairs);
          }
        });
        sanitizedData.tetrioPlusEnabled = true;

        console.log("Loaded content pack from " + url + ". Result:\n" + result);
        return sanitizedData;
      })().catch(ex => {
        console.error(ex);
        return null;
      });

      // Empty cache after 10 minutes. This should be enough time to load
      // the page and then play a few games (since music isn't fetched until
      // its played). We don't want to store it for too long though - content
      // packs can become absolutely positively downright enourmous.
      setTimeout(() => {
        delete REQUEST_CACHE[url];
        console.log("Cleared cached request for", url)
      }, 10 * 60 * 1000);
    }

    return await REQUEST_CACHE[url];
  } catch(ex) {
    console.error(ex);
    return null;
  }
}

async function getDataSourceForDomain(urlString) {
  let data = await getDataForDomain(urlString);
  if (data) {
    return {
      async get(keys) {
        // Prevent infinite loops in some users that don't expect
        // the promise to resolve syncronously
        await new Promise(r => setTimeout(r));
        return data; // It's technically complient
      }
    }
  } else {
    return browser.storage.local;
  }
}

if (typeof module != 'undefined' && module.exports)
  module.exports = getDataSourceForDomain;
