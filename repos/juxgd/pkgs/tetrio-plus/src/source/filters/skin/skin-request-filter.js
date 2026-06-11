[
  { skin: 'minos/connected.2x.png', key: 'skin', name: 'Custom skin' },
  { skin: 'ghost/connected.2x.png', key: 'ghost', name: 'Custom skin (ghost)' },
  { skin: 'minos/connected.png?animated', key: 'skinAnim', name: 'Animated skin' },
  { skin: 'ghost/connected.png?animated', key: 'ghostAnim', name: 'Animated skin (ghost)' },
].forEach(({ skin, key, name }) => {
  createRewriteFilter(name, `https://tetr.io/res/skins/${skin}`, {
    enabledFor: async (storage, url) => {
      return !!(await storage.get(key))[key];
    },
    onStop: async (storage, url, src, callback) => {
      callback({
        type: 'image/png',
        data: (await storage.get(key))[key],
        encoding: 'base64-data-url'
      });
    }
  });
});
