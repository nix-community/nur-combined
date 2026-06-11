// SkinSplicer v2.0.0 by UniQMG
export const TETRIO_CONNECTIONS_SUBMAP = {
  // key = corner (T, L, J, S, Z), top, right, bottom, left (1=open,0=closed)
  0b00010: [[0, 0]],
  0b00110: [[1, 0]],
  0b00111: [[2, 0]],
  0b00011: [[3, 0]],
  0b01010: [[0, 1]],
  0b01110: [[1, 1]],
  0b01111: [[2, 1]],
  0b01011: [[3, 1]],
  0b01000: [[0, 2]],
  0b01100: [[1, 2]],
  0b01101: [[2, 2]],
  0b01001: [[3, 2]],
  0b00000: [[0, 3]],
  0b00100: [[1, 3]],
  0b00101: [[2, 3]],
  0b00001: [[3, 3]],
  // corner sides
  0b10110: [[0, 4]],
  0b10011: [[1, 4]],
  0b11101: [[2, 4]],
  0b11110: [[3, 4]],
  0b11100: [[0, 5]],
  0b11001: [[1, 5]],
  0b10111: [[2, 5]],
  0b11011: [[3, 5]]
};
export const TETRIO_GARBAGE_CONNECTIONS_SUBMAP = Object.fromEntries( // no corners
  Object.entries(TETRIO_CONNECTIONS_SUBMAP).filter(([k,v]) => !(k&0b10000))
);
export const NO_CONN_SUBMAP = { 0: [[0, 0]] }

export const JSTRIS_DIMPLES = {
  TOP_RIGHT: [0, 16],
  BOTTOM_RIGHT: [0, 17],
  BOTTOM_LEFT: [0, 18],
  TOP_LEFT: [0, 19]
}
export const JSTRIS_CONNECTIONS_SUBMAP = {
  0b00000: [[0,  0]],
  0b01000: [[0,  1]],
  0b00010: [[0,  2]],
  0b01010: [[0,  3]],
  0b00001: [[0,  4]],
  0b11001: [[0,  5]],
  0b10011: [[0,  6]],
  0b11011: [[0,  7]],
  0b00100: [[0,  8]],
  0b11100: [[0,  9]],
  0b10110: [[0, 10]],
  0b11110: [[0, 11]],
  0b00101: [[0, 12]],
  0b11101: [[0, 13]],
  0b10111: [[0, 14]],
  0b11111: [[0, 15]],

  0b01100: [[0,  9], JSTRIS_DIMPLES.TOP_RIGHT],
  0b00110: [[0, 10], JSTRIS_DIMPLES.BOTTOM_RIGHT],
  0b00011: [[0,  6], JSTRIS_DIMPLES.BOTTOM_LEFT],
  0b01001: [[0,  5], JSTRIS_DIMPLES.TOP_LEFT],

  0b00111: [[0, 14], JSTRIS_DIMPLES.BOTTOM_RIGHT, JSTRIS_DIMPLES.BOTTOM_LEFT],
  0b01011: [[0,  7], JSTRIS_DIMPLES.TOP_LEFT, JSTRIS_DIMPLES.BOTTOM_LEFT],
  0b01101: [[0, 13], JSTRIS_DIMPLES.TOP_LEFT, JSTRIS_DIMPLES.TOP_RIGHT],
  0b01110: [[0, 11], JSTRIS_DIMPLES.BOTTOM_RIGHT, JSTRIS_DIMPLES.TOP_RIGHT],

  0b01111: [[0, 15], ...Object.values(JSTRIS_DIMPLES)]
}

export const TETRIO_61_MAP = {
  z:    { x:  0 * 6/32, y:  0 * 6/32, w: 6/32, h: 6/32 },
  l:    { x:  1 * 6/32, y:  0 * 6/32, w: 6/32, h: 6/32 },
  o:    { x:  2 * 6/32, y:  0 * 6/32, w: 6/32, h: 6/32 },
  s:    { x:  3 * 6/32, y:  0 * 6/32, w: 6/32, h: 6/32 },
  i:    { x:  4 * 6/32, y:  0 * 6/32, w: 6/32, h: 6/32 },
  j:    { x:  0 * 6/32, y:  1 * 6/32, w: 6/32, h: 6/32 },
  t:    { x:  1 * 6/32, y:  1 * 6/32, w: 6/32, h: 6/32 },
  hold: { x:  2 * 6/32, y:  1 * 6/32, w: 6/32, h: 6/32 },
  gb:   { x:  3 * 6/32, y:  1 * 6/32, w: 6/32, h: 6/32 },
  dgb:  { x:  4 * 6/32, y:  1 * 6/32, w: 6/32, h: 6/32 }
};
export const TETRIO_61_GHOST_MAP = {
  ghost:  { x: 0/8, y: 0, w: 3/8, h: 3/8 },
  topout: { x: 3/8, y: 0, w: 3/8, h: 3/8 }
};
export const TETRIO_61_CONN_MAP = {
  z:    { x:  0 * 6/32, y:  0 * 9/32, w: 6/32, h: 9/32, map: TETRIO_CONNECTIONS_SUBMAP },
  l:    { x:  1 * 6/32, y:  0 * 9/32, w: 6/32, h: 9/32, map: TETRIO_CONNECTIONS_SUBMAP },
  o:    { x:  2 * 6/32, y:  0 * 9/32, w: 6/32, h: 9/32, map: TETRIO_CONNECTIONS_SUBMAP },
  s:    { x:  3 * 6/32, y:  0 * 9/32, w: 6/32, h: 9/32, map: TETRIO_CONNECTIONS_SUBMAP },
  i:    { x:  0 * 6/32, y:  1 * 9/32, w: 6/32, h: 9/32, map: TETRIO_CONNECTIONS_SUBMAP },
  j:    { x:  1 * 6/32, y:  1 * 9/32, w: 6/32, h: 9/32, map: TETRIO_CONNECTIONS_SUBMAP },
  t:    { x:  2 * 6/32, y:  1 * 9/32, w: 6/32, h: 9/32, map: TETRIO_CONNECTIONS_SUBMAP },
  hold: { x:  3 * 6/32, y:  1 * 9/32, w: 6/32, h: 9/32, map: TETRIO_CONNECTIONS_SUBMAP },
  gb:   { x:  4 * 6/32, y:  0 * 6/32, w: 6/32, h: 6/32, map: TETRIO_GARBAGE_CONNECTIONS_SUBMAP },
  dgb:  { x:  4 * 6/32, y:  1 * 6/32, w: 6/32, h: 6/32, map: TETRIO_GARBAGE_CONNECTIONS_SUBMAP }
};
export const TETRIO_61_CONN_GHOST_MAP = {
  ghost:  { x: 0/16, y: 0, w: 6/16, h: 9/16, map: TETRIO_CONNECTIONS_SUBMAP },
  topout: { x: 6/16, y: 0, w: 6/16, h: 9/16, map: TETRIO_CONNECTIONS_SUBMAP }
};
export const TETRIO_MAP = {
  z:      { x:     0, y: 0, w: 1/12.4, h: 1 },
  l:      { x:  1/12, y: 0, w: 1/12.4, h: 1 },
  o:      { x:  2/12, y: 0, w: 1/12.4, h: 1 },
  s:      { x:  3/12, y: 0, w: 1/12.4, h: 1 },
  i:      { x:  4/12, y: 0, w: 1/12.4, h: 1 },
  j:      { x:  5/12, y: 0, w: 1/12.4, h: 1 },
  t:      { x:  6/12, y: 0, w: 1/12.4, h: 1 },
  ghost:  { x:  7/12, y: 0, w: 1/12.4, h: 1 },
  hold:   { x:  8/12, y: 0, w: 1/12.4, h: 1 },
  gb:     { x:  9/12, y: 0, w: 1/12.4, h: 1 },
  dgb:    { x: 10/12, y: 0, w: 1/12.4, h: 1 },
  topout: { x: 11/12, y: 0, w: 1/12.4, h: 1 },
};
export const JSTRIS_MAP = {
  z:      { x: 2/9, y: 0, w: 1/9, h: 1 },
  l:      { x: 3/9, y: 0, w: 1/9, h: 1 },
  o:      { x: 4/9, y: 0, w: 1/9, h: 1 },
  s:      { x: 5/9, y: 0, w: 1/9, h: 1 },
  i:      { x: 6/9, y: 0, w: 1/9, h: 1 },
  j:      { x: 7/9, y: 0, w: 1/9, h: 1 },
  t:      { x: 8/9, y: 0, w: 1/9, h: 1 },
  ghost:  { x: 1/9, y: 0, w: 1/9, h: 1 },
  hold:   { x: 0/9, y: 0, w: 1/9, h: 1 },
  gb:     { x: 0/9, y: 0, w: 1/9, h: 1 },
  dgb:    { x: 0/9, y: 0, w: 1/9, h: 1 },
  topout: { x: 0/9, y: 0, w: 1/9, h: 1 },
};
export const JSTRIS_CONN_MAP = {
  z:      { x: 2/9, y: 0, w: 1/9, h: 1, map: JSTRIS_CONNECTIONS_SUBMAP },
  l:      { x: 3/9, y: 0, w: 1/9, h: 1, map: JSTRIS_CONNECTIONS_SUBMAP },
  o:      { x: 4/9, y: 0, w: 1/9, h: 1, map: JSTRIS_CONNECTIONS_SUBMAP },
  s:      { x: 5/9, y: 0, w: 1/9, h: 1, map: JSTRIS_CONNECTIONS_SUBMAP },
  i:      { x: 6/9, y: 0, w: 1/9, h: 1, map: JSTRIS_CONNECTIONS_SUBMAP },
  j:      { x: 7/9, y: 0, w: 1/9, h: 1, map: JSTRIS_CONNECTIONS_SUBMAP },
  t:      { x: 8/9, y: 0, w: 1/9, h: 1, map: JSTRIS_CONNECTIONS_SUBMAP },
  ghost:  { x: 1/9, y: 0, w: 1/9, h: 1, map: JSTRIS_CONNECTIONS_SUBMAP },
  hold:   { x: 0/9, y: 0, w: 1/9, h: 1, map: JSTRIS_CONNECTIONS_SUBMAP },
  gb:     { x: 0/9, y: 0, w: 1/9, h: 1, map: JSTRIS_CONNECTIONS_SUBMAP },
  dgb:    { x: 0/9, y: 0, w: 1/9, h: 1, map: JSTRIS_CONNECTIONS_SUBMAP },
  topout: { x: 0/9, y: 0, w: 1/9, h: 1, map: JSTRIS_CONNECTIONS_SUBMAP },
};

export default class SkinSplicer {
  constructor(format, images) {
    this.format = format;
    this.images = images.map(img => {
      if (img instanceof HTMLCanvasElement)
        return img;
      let canvas = window.document.createElement('canvas');
      canvas.width = img.width;
      canvas.height = img.height;
      canvas.getContext('2d').drawImage(img, 0, 0);
      return canvas;
    });
    this.orderedImages = this.images.slice().sort((a,b) => {
      if (a.width == b.width) return 0;
      return a.width > b.width ? -1 : 1;
    });
  }

  stats() {
    switch (this.format) {
      case 'tetriosvg':
      case 'tetrioraster':
      case 'tetrioanim':
        return [TETRIO_MAP];

      case 'jstrisraster':
      case 'jstrisanim':
        return [JSTRIS_MAP];

      case 'jstrisconnected':
        return [JSTRIS_CONN_MAP];

      case 'tetrio61':
        return [TETRIO_61_MAP];

      case 'tetrio61ghost':
        return [TETRIO_61_GHOST_MAP];

      case 'tetrio61multi':
        return [TETRIO_61_MAP, TETRIO_61_GHOST_MAP];

      case 'tetrio61connected':
      case 'tetrio61connectedanimated':
        return [TETRIO_61_CONN_MAP];

      case 'tetrio61connectedghost':
      case 'tetrio61connectedghostanimated':
        return [TETRIO_61_CONN_GHOST_MAP];

      case 'tetrio61connectedmulti':
        return [TETRIO_61_CONN_MAP, TETRIO_61_CONN_GHOST_MAP];
    }
  }

  set(piece, connection, texture) {
    if (!texture) return false;

    let pieceinfo = this.get(piece, connection, null);
    if (!pieceinfo) return false;

    for (let [img, x, y, w, h] of pieceinfo) {
      img.getContext('2d').drawImage(texture, x, y, w, h);
    }

    return true;
  }

  get(piece, connection, defaultConnection=0) {
    let imap = this.stats()
      .map((el, i) => [i, el])
      .filter(([i, el]) => el[piece])[0];
    if (!imap) return null;
    let [i, map] = imap;
    let img = this.orderedImages[i];
    let { x, y, w, h, map: connmap } = map[piece];

    connmap = connmap || NO_CONN_SUBMAP;
    let [mx, my] = Object.values(connmap)
      .flatMap(entries => entries)
      .reduce(([x1, y1], [x2, y2]) => {
        return [Math.max(x1, x2), Math.max(y1, y2)];
      });

    let cmapCoords = connmap[connection] || connmap[defaultConnection];
    if (!cmapCoords) return null;

    return cmapCoords.map(([cx, cy]) => {
      let stepX = w / (mx + 1);
      let stepY = h / (my + 1);
      let nx = Math.floor((x + stepX * cx) * img.width);
      let ny = Math.floor((y + stepY * cy) * img.height);
      let nw = Math.floor(stepX * img.width);
      let nh = Math.floor(stepY * img.height);
      return [img, nx, ny, nw, nh]; // arguments to drawImage
    });
  }
}
