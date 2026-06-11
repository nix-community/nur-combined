(() => {
  function matchBalanced(string, startPos=0) {
    let brackets = { '{': 0, '[': 0, '(': 0 };
    let close = { '}': '{', ']': '[', ')': '(' };

    for (let i = startPos; i < string.length; i++) {
      if (string[i] in brackets)
        brackets[string[i]]++;

      if (close[string[i]])
        brackets[close[string[i]]]--;

      if (brackets['{'] == 0 && brackets['['] == 0 && brackets['('] == 0)
        return i;
    }

    throw new Error("Reached end of string while searching for bracket pairs");
  }
  const tetrioWinterCode = b => `;
    this.textures.set("board", PIXI.BaseTexture.from("/res/skins/board/generic/board.png")),
    this.elements.set("background", new ${b}.generic.ns.background(this, {
      texture: new PIXI.Texture(this.textures.get("board"), new PIXI.Rectangle(258, 2, 252, 252)),
      texture_tiny: new PIXI.Texture(this.textures.get("board"), new PIXI.Rectangle(22, 2, 26, 16)),
      slices: [124, 0, 124, 0],
      slices_tiny: [10, 0, 10, 10],
      offsets_tiny: [10, 0, 10, 10]
    })),
    this.elements.set("border", new ${b}.generic.ns.border(this, {
      texture: new PIXI.Texture(this.textures.get("board"), new PIXI.Rectangle(258, 258, 252, 252)),
      slices: [9, 0, 9, 9],
      offsets: [9, 0, 9, 9]
    })),
    t.setoptions.slot_bar2 && (
      this.elements.set("bar2", new ${b}.generic.ns.bar_smooth(this, {
        side: "right",
        bar_texture: new PIXI.Texture(this.textures.get("board"), new PIXI.Rectangle(173, 2, 27, 18)),
        bar_slices: [9, 0, 9, 9],
        bar_offsets: [9, 0, 9, 9],
        offset: this.barWidthOffset,
        fill_texture: new PIXI.Texture(this.textures.get("board"), new PIXI.Rectangle(175, 24, 60, 60)),
        fill_slices: [0, 30, 0, 0],
        fill_offsets: [0, 30, 0, 0],
        ticker_texture: new PIXI.Texture(this.textures.get("board"), new PIXI.Rectangle(111, 88, 60, 8)),
        colors: [5551305, 2729922],
        flash_color: 2729922
      })),
      this.progressive.set("bar2", this.elements.get("bar2"))
    );
  `;
  createRewriteFilter("Winter compat", "https://tetr.io/js/tetrio.js*", {
    enabledFor: async (storage, request) => {
      let { winterCompatEnabled, board } = await storage.get([
        'winterCompatEnabled',
        'board'
      ]);
      if (!winterCompatEnabled || !board)
        return false;

      let width = 0;
      let height = 0;
      if (typeof image_size != 'undefined') { // electron main polyfill
        let size = await image_size(Buffer.from(board.split(',')[1], 'base64'));
        width = size.width;
        height = size.height;
      } else { // firefox
        let img = new Image();
        await new Promise(res => {
          img.onload = res;
          img.onerror = res;
          img.src = board;
        });
        width = img.width;
        height = img.height;
      }
      console.log("[Winter compat filter] Image size", width, height);
      return width >= 1024 && height >= 1024;
    },
    onStop: async (storage, url, src, callback) => {
      try {
        // Regex for targeting the board constructor up to but not including
        // the constructor left bracket
        let regex = /[$_\w]{1,3}\.generic\.[$_\w]{0,3}\.Board=class\s*extends\s*[$_\w]{0,3}{\s*constructor\([$_\w,]+\)\s*/;
        let match = regex.exec(src);
        if (!match) throw "Regex #1 didn't match";
        let match2 = /(\w+)\.generic\.ns\.bar_smooth/.exec(src);
        if (!match2) throw "Regex #2 didn't match";
        let end = matchBalanced(src, match.index + match[0].length);
        src = src.slice(0, end) + tetrioWinterCode(match2[1]) + src.slice(end);
      } catch(ex) {
        console.warn('Winter compat hook broke:', ex);
      } finally {
        callback({ type: 'text/javascript', data: src, encoding: 'text' });
      }
    }
  });
})();
