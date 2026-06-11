/*
  This filter rewrites the binary music files based on a
  query parameter added by the music-tetriojs-filter script
  in order to load user-specified custom music.
*/
createRewriteFilter("Music Request", "https://tetr.io/res/bgm/*", {
  enabledFor: async (storage, url) => {
    let { musicEnabled, music, disableVanillaMusic } = await storage.get(
      ['musicEnabled', 'music', 'disableVanillaMusic']
    );
    if (!musicEnabled || (!music && !disableVanillaMusic)) return false;

    // song requests are rewritten as
    // `https://tetr.io/res/bgm/<some base game song>.mp3?song=<tetrioplus id>&tetrioplusinjectioncomment=.mp3`
    // so they still always end in `.mp3`
    let [_, songname] = /bgm\/(.+).mp3$/.exec(url);
    let overrides = music.filter(song => song.override == songname);
    if (disableVanillaMusic || overrides.length > 0)
      return true;

    let match = /\?song=([^&]+)/.exec(url);
    if (!match) {
      console.log("[Music Request filter] Ignoring, no song ID or overrides:", url);
      return false;
    }
    return true;
  },
  onStart: async (storage, url, src, callback) => {
    let match = /\?song=([^&]+)/.exec(url);
    if (!match) {
      let { music } = await storage.get('music');
      let [_, songname] = /bgm\/(.+).mp3$/.exec(url);
      let override = music.filter(song => song.override == songname)[0];
      if (override) {
        console.log("[Music Request filter] Override ID", override.id, { url });
        let key = `song-${override.id}`;
        let value = (await storage.get(key))[key];
        callback({
          type: 'audio/mpeg',
          data: value,
          encoding: 'base64-data-url'
        });
      } else {
        // no override, we should have gotten here due to `disableVanillaMusic`
        // return blank audio (empty wav file), as the game is attempting to load a vanilla track
        console.log("[Music Request filter] No song ID, returning empty audio file", { url });
        callback({
          type: 'audio/wav',
          data: 'data:audio/wav;base64,UklGRkYAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAATElTVBoAAABJTkZPSVNGVA4AAABMYXZmNjAuMTYuMTAwAGRhdGEAAAAA',
          encoding: 'base64-data-url'
        });
      }
    } else {
      let [_, songId] = match;
      console.log("[Music Request filter] Song ID", songId, { url });

      let key = `song-${songId}`;
      let value = (await storage.get(key))[key];
      callback({
        type: 'audio/mpeg',
        data: value,
        encoding: 'base64-data-url'
      });
    }
  }
});
