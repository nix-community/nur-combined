/*
  This filter sets the `transparent: true` attribute on the pixi
  application constructor arguments that tetrio uses.

  A content script then inserts the animated background as a DOM
  element underneath the pixijs canvas.
*/
createRewriteFilter("Tetrio.js Animated BG", "https://tetr.io/js/tetrio.js*", {
  enabledFor: async (storage, request) => {
    let res = await storage.get([
      'bgEnabled',
      'animatedBgEnabled',
      'transparentBgEnabled',
      'musicGraphBackground'
    ]);
    if (res.transparentBgEnabled) return true;
    if (res.bgEnabled && res.animatedBgEnabled) return true;
    if (res.musicGraphBackground) return true;
    return false;
  },
  onStop: async (storage, url, src, callback) => {
    let regex = /(new PIXI\.Application\({[^}]+)(transparent:[^,]+),([^}]+}\))/g;
    let newSrc = src.replace(regex, '$1transparent:true,$3');
    if (newSrc === src) console.log(
      "Animated custom background rewrite failed. " +
      "Please update your plugin. "
    );
    callback({
      type: 'text/javascript',
      data: newSrc,
      encoding: 'text'
    });
    // filter.write(new TextEncoder().encode(newSrc));
  }
});
