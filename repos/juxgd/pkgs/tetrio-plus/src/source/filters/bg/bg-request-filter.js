/*
  This filter rewrites requests for background images with a given
  query parameter and replaces them with user-specified backgrounds.
*/
createRewriteFilter("Bg Request", "https://tetr.io/res/bg/*", {
  enabledFor: async (storage, url) => {
    let match = /\?bgId=([^&]+)/.exec(url);
    if (!match) {
      console.log("[Bg Request filter] Ignoring, no bg ID:", url);
      return false;
    }
    return true;
  },
  onStart: async (storage, url, src, callback) => {
    let [_, bgId] = /\?bgId=([^&]+)/.exec(url);
    console.log("[Bg Request filter] Background ID", bgId);

    if (bgId == 'animated') {
      let res = await storage.get('animatedBackground');
      let animBg = res.animatedBackground;
      if (!animBg) return;
      let key = 'background-' + animBg.id;
      let value = (await storage.get(key))[key];
      callback({
        type: dataUriMime(value),
        data: value,
        encoding: 'base64-data-url'
      });
      return;
    }

    if (bgId == 'transparent') {
      let { opaqueTransparentBackground } = await storage.get(
        'opaqueTransparentBackground'
      );
      callback({
        type: 'image/png',
        data: opaqueTransparentBackground
          // 1x1 black pixel
          ? `data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1P` +
            `eAAAACXBIWXMAAC4jAAAuIwF4pT92AAAAB3RJTUUH5AYVBwk0XL/4QAAAABl0RVh0` +
            `Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUFeBDhcAAAAMSURBVAjXY2BgYAAAAAQAA` +
            `Sc0JwoAAAAASUVORK5CYII=`
          // 1x1 transparent pixel
          : `data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ` +
            `AAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAB3RJTUUH5A` +
            `QWBjQ7z1871gAAAAtJREFUCNdjYAACAAAFAAHiJgWbAAAAAElFTkSuQmCC`,
        encoding: 'base64-data-url'
      });
      // filter.write(value);
      return;
    }

    let key = `background-${bgId}`;
    let value = (await storage.get(key))[key];
    callback({
      type: dataUriMime(value),
      data: value,
      encoding: 'base64-data-url'
    });
  }
});

function dataUriMime(uri) {
  return /^data:([^;]+);/.exec(uri)[1];
}
