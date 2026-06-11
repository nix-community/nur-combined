const TABS_TO_URL = {

}

browser.runtime.onConnect.addListener(port => {
  if (port.name != 'info-channel') return;
  console.log("New content script connection");
  port.onMessage.addListener(async (msg, sender) => {
    console.log(msg);
    switch (msg.type) {
      case 'getUrlFromTab':
        port.postMessage({
          type: 'getUrlFromTabResult',
          url: TABS_TO_URL[msg.tabId]
        });
        break;

      case 'fetchContentPack':
        TABS_TO_URL[port.sender.tab.id] = msg.url;
        port.postMessage({
          type: 'fetchContentPackResult',
          value: await getDataForDomain(msg.url)
        });
        break;

      case 'openMapEditor':
        browser.tabs.create({
          url: browser.extension.getURL('source/panels/mapeditor/index.html') +
               '?map=' + encodeURIComponent(msg.map),
          active: true
        });
        break;

      case 'showPageAction':
        if (browser.pageAction)
          browser.pageAction.show(sender.sender.tab.id);
        break;

      case 'saveReplay':
        let suffix = '_';
        try {
          let users = JSON.parse(msg.replay)?.data[0]?.board?.map(board => board.username.replace(/[^A-Za-z0-9]/g, ''));
          suffix = users.length > 2
            ? `_${users.length}-players`
            : '_' + users.join(',');

          // should be unenterable, max username length is 16 (=34 max chars for 2 players),
          // usernames are always alphanumeric & -_, and we already filter them above anyway
          // in case of attempted malicious injection.
          if (suffix.length > 100 || /[^A-Za-z0-9,-_]/.test(suffix))
            throw new Error("Illegal replay suffix");
        } catch(ex) {
          console.log('[TETR.IO PLUS] warn: failed to determine players in replay', ex);
        }

        let blob = new Blob([msg.replay], { type: "application/json;charset=utf-8" });
        let url = URL.createObjectURL(blob);
        let date = (new Date()).toISOString().replace(/:/g, '-').replace('T', '_').replace(/\.\d+[A-Z]$/, '');
        browser.downloads.download({
          filename: 'tetrio-plus-replays/replay_multi_' + date + suffix + '.ttrm',
          url: url,
          saveAs: false
        }).finally(() => {
          URL.revokeObjectURL(url)
        });
        break;

      case 'getInfoString':
        let manifestUri = browser.runtime.getURL('manifest.json');
        let manifest = await (await fetch(manifestUri)).json();
        let version = manifest.version;

        let strings = {
          'bgEnabled': 'custom block skin',
          'animatedBgEnabled': 'animated backgrounds',
          'transparentBgEnabled': 'transparent background',
          'opaqueTransparentBackground': 'opaque background layer',
          'musicEnabled': 'custom music',
          'musicGraphEnabled': 'music graph',
          'disableVanillaMusic': 'disable built-in music',
          'enableMissingMusicPatch': 'missing music patch',
          'sfxEnabled': 'custom sfx',
          'skin': 'custom block skins',
          'enableCustomMaps': 'custom maps',
          'enableAllSongTweaker': 'All Songs in music tweaker',
          'enableOSD': 'key display',
          'enableReplaySaver': 'replay saver',
          'enableTouchControls': 'touch controls',
          'enableEmoteTab': 'emote tab',
          'bypassBootstrapper': 'bootstrap.js bypass',
          'openDevtoolsOnStart': 'automatic devtools',
          'debugBreakTheGame': 'DEBUG: INTENTIONALLY BREAK THE GAME'
        }

        let config = await browser.storage.local.get(Object.keys(strings));
        let features = [];

        for (let [key, str] of Object.entries(strings))
          if (config[key]) features.push(str);

        let featureString = features.length > 0
          ? features.join(', ')
          : 'none';

        let { name } = await browser.runtime.getBrowserInfo();

        port.postMessage({
          type: 'getInfoStringResult',
          value: `TETR.IO PLUS v${version} on ${name}. Features enabled: ${featureString}`
        });
        break;

      default:
        throw new Error('Unknown message type ' + msg.type);
    }
  });
});
