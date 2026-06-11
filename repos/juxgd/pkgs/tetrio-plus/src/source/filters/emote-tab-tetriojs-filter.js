/* Added by Jabster28 | MIT Licensed */
createRewriteFilter("Emote tabbing hooks", "https://tetr.io/js/tetrio.js*", {
  enabledFor: async (storage, request) => {
    let res = await storage.get('enableEmoteTab');
    return res.enableEmoteTab;
  },
  onStop: async (storage, url, src, callback) => {
    // This patch exposes the game's emote map as a global variable
    // which is used for up to date emote suggestions from the injected emote picker script
    let patched = false;
    // Emotes changed a bit recently, they're now an array with some duplicates. Entries get
    // normalized and shoved into a global object which is similar-ish to the old one. This
    // regex is targeting a function that inserts a single item into the list (so there's
    // an explicit check to see if the emoteMap was already defined). A partial view of the list
    // shouldn't be a problem since the whole thing is initialized synchronously.
    // Permissions were moved to an integer `access` field, with similar but obfuscated levels:
    // 1=base, 2=supporter, 3=verified, 4=staff
    let reg1 = /([\w$]{1,4})\[`:\${\s*[\w$]{1,4}\.toLowerCase\(\)\s*}:`\]\s*=\s*[\w$]{1,4};/;
    src = src.replace(reg1, (match, varName) => {
      patched = true;
      return match + `;
        if (!window.emoteMap)
        Object.defineProperty(window, "emoteMap", {
          get: () => ${varName}
        });
      `;
    });
    if (!patched) console.log('Emote tabbing hooks broke');

    callback({
      type: 'text/javascript',
      data: src,
      encoding: 'text'
    });
  }
})
