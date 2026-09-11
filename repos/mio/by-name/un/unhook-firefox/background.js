// Chrome/Firefox compatibility
const browserAPI = globalThis.browser || globalThis.chrome;

// In-memory flag for the common case (sync blocking response).
let redirectToSubscriptions = false;
let settingsReady = false;

function syncRedirectSetting(value) {
  redirectToSubscriptions = value === true;
}

const settingsReadyPromise = browserAPI.storage.local.get(null).then((settings) => {
  syncRedirectSetting(settings.redirectToSubscriptions);
  settingsReady = true;
});

browserAPI.storage.onChanged.addListener((changes, area) => {
  if (area !== 'local' || !changes.redirectToSubscriptions) {
    return;
  }
  syncRedirectSetting(changes.redirectToSubscriptions.newValue);
  settingsReady = true;
});

function shouldRedirectHome(urlString) {
  if (!redirectToSubscriptions) {
    return false;
  }
  try {
    const url = new URL(urlString);
    if (url.hostname !== 'www.youtube.com') {
      return false;
    }
    const path = url.pathname;
    return path === '/' || path === '/feed/trending';
  } catch {
    return false;
  }
}

function redirectResult(urlString) {
  if (!shouldRedirectHome(urlString)) {
    return {};
  }
  return { redirectUrl: 'https://www.youtube.com/feed/subscriptions' };
}

function onBeforeRequest(details) {
  // Only main-frame navigations; never touch XHR/fetch/images.
  if (details.type && details.type !== 'main_frame') {
    return {};
  }
  // Fast path once settings are known.
  if (settingsReady) {
    return redirectResult(details.url);
  }
  // Cold start: Firefox allows a Promise from a blocking listener so the first
  // navigation still redirects before the home document is delivered.
  return settingsReadyPromise.then(() => redirectResult(details.url));
}

browserAPI.webRequest.onBeforeRequest.addListener(
  onBeforeRequest,
  {
    urls: [
      '*://www.youtube.com/',
      '*://www.youtube.com/?*',
      '*://www.youtube.com/feed/trending',
      '*://www.youtube.com/feed/trending?*',
    ],
    types: ['main_frame'],
  },
  ['blocking']
);
