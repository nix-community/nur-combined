export const SKIN  = [256, 256, [0, 1, 2, 3, 4, 5, 6, /*skip ghost */ 8, 9, 10 /*skip topout*/]];
export const GHOST = [128, 128, [7, 11]];
export default function(image, type, f=2) { // f=scale factor
  const [width, height, sourceRemap] = type;
  const canvas = window.document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  canvas.width = width*f;
  canvas.height = height*f;
  // Tetrio format: https://tetr.io/res/skins/minos/tetrio.png
  // New format doesn't include ghost or topout indicators
  for (let block = 0; block < sourceRemap.length; block++) {
    let src_x = sourceRemap[block] * image.width / 12;
    let src_y = 0;
    let src_w = image.width / 12.4;
    let src_h = image.height;
    let dest_x = 48*f * (block % 5);
    let dest_y = 48*f * Math.floor(block / 5);
    let dest_w = 48*f;
    let dest_h = 48*f;
    ctx.drawImage(image,src_x,src_y,src_w,src_h,dest_x,dest_y,dest_w,dest_h);
  }
  return canvas;
}
