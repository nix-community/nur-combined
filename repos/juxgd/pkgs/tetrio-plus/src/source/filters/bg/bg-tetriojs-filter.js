/*
  This filter rewrites the bg definition in tetrio.js
  in order to add support for custom backgrounds served
  from the extension.
*/

createRewriteFilter("Tetrio.js BG", "https://tetr.io/js/tetrio.js*", {
  enabledFor: async (storage, request) => {
    let res = await storage.get([
      'musicGraphBackground',
      'transparentBgEnabled',
      'animatedBackground',
      'animatedBgEnabled',
      'backgrounds',
      'bgEnabled'
    ]);

    if (res.musicGraphBackground)
      return true;

    if (res.transparentBgEnabled)
      return true;

    if (!res.bgEnabled)
      return false;

    if (res.animatedBgEnabled && res.animatedBackground)
      return true;

    if (res.backgrounds && res.backgrounds.length > 0)
      return true;

    return false;
  },
  onStop: async (storage, url, src, callback) => {
    let res = await storage.get([
      'musicGraphBackground',
      'transparentBgEnabled',
      'animatedBgEnabled',
      'animatedBackground',
      'backgrounds'
    ]);

    let backgrounds = [];
    if (res.musicGraphBackground) {
      backgrounds.push({ id: 'transparent', type: 'image' });
    } else if (res.transparentBgEnabled) {
      backgrounds.push({ id: 'transparent', type: 'image' });
    } else if (res.animatedBgEnabled && res.animatedBackground) {
      backgrounds.push({ id: 'transparent', type: 'image' });
    } else if (res.backgrounds) {
      backgrounds.push(...res.backgrounds)
    }

    let replaced = 0;
    src = src.replace(
      /(\w+=)(\[["']\.\.\/res\/bg.+?\])/g,
      (fullmatch, varInit, value) => {
        let rewrite = varInit + b64Recode(backgrounds.filter(bg => {
          return bg.type == 'image';
        }).map(bg => {
          return `../res/bg/1.jpg?bgId=${bg.id}`
        }));
        // console.log(
        //   "Rewriting backgrounds definition",
        //   { from: fullmatch, to: rewrite }
        // );
        replaced++;
        return rewrite;
      }
    );

    if (replaced != 1) console.error(
      `Custom background rewrite matched ${replaced} times, but only expected 1. ` +
      `(or 2 in case of the holiday event. You can ignore this error if it was 2 and that's still going on)`
    );

    callback({
      type: 'text/javascript',
      data: src,
      encoding: 'text'
    });

    // filter.write(new TextEncoder().encode(src));
  }
});
