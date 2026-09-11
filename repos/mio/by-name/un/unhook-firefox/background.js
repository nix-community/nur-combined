// Chrome/Firefox compatibility
const browserAPI = globalThis.browser || globalThis.chrome;

// Keep redirect decision in-memory so the blocking webRequest listener can
// answer synchronously (awaiting storage in a blocking listener is too late).
let redirectToSubscriptions = false;

function syncRedirectSetting(value) {
  redirectToSubscriptions = value === true;
}

browserAPI.storage.local.get(null).then((settings) => {
  syncRedirectSetting(settings.redirectToSubscriptions);
});

browserAPI.storage.onChanged.addListener((changes, area) => {
  if (area !== 'local' || !changes.redirectToSubscriptions) {
    return;
  }
  syncRedirectSetting(changes.redirectToSubscriptions.newValue);
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

function onBeforeRequest(details) {
  // Only main-frame navigations; never touch XHR/fetch/images.
  if (details.type && details.type !== 'main_frame') {
    return {};
  }
  if (!shouldRedirectHome(details.url)) {
    return {};
  }
  return { redirectUrl: 'https://www.youtube.com/feed/subscriptions' };
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
