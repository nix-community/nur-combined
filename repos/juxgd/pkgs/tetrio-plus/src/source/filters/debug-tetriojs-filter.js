createRewriteFilter("Break the game hooks", "https://tetr.io/js/tetrio.js*", {
  enabledFor: async (storage, request) => {
    let res = await storage.get('debugBreakTheGame');
    return res.debugBreakTheGame;
  },
  onStart: async (storage, url, src, callback) => {
    callback({
      type: 'text/javascript',
      data: `console.log("` +
        `TETRIO PLUS> ` +
        `The game is intentionally broken. ` +
        `Turn off the 'Break the game' option.` +
      `")`,
      encoding: 'text'
    });
  }
})