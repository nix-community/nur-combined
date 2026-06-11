import SkinSplicer, * as maps from './util/skin-splicer.js';

export default function(image) {
  let skin = window.document.createElement('canvas');
  skin.width = 2048;
  skin.height = 2048;

  let ghost = window.document.createElement('canvas');
  ghost.width = 1024;
  ghost.height = 1024;

  let source = new SkinSplicer('jstrisconnected', [image]);
  let dest = new SkinSplicer('tetrio61connectedmulti', [skin, ghost]);

  let pieces = [
    ...Object.keys(maps.TETRIO_61_CONN_MAP),
    ...Object.keys(maps.TETRIO_61_CONN_GHOST_MAP)
  ];
  let temp = document.createElement('canvas');
  for (let piece of pieces) {
    for (let conns of Object.keys(maps.TETRIO_CONNECTIONS_SUBMAP)) {// TODO: use tetrio map
      if (conns.startsWith('_')) continue;
      let drawCalls = source.get(piece, conns);

      for (let [tex, x, y, w, h] of drawCalls) {
        temp.width = w;
        temp.height = h;
        
        let ctx = temp.getContext('2d');
        ctx.clearRect(0, 0, w, h);
        ctx.drawImage(tex, x, y, w, h, 0, 0, w, h);

        let res = dest.set(piece, conns, temp);
        console.log(piece, conns.toString(2), '->', x, y, w, h, '?', res);
      }
    }
  }

  return [skin, ghost];
}
