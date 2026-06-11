export default function(image, f=2) { // f=scale factor
  const canvas = window.document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  canvas.width = 1024*f;
  canvas.height = 1024*f;

  let srcBlockSize = image.width * 48 / 256;
  let srcColumns = 5;

  // connected format: https://tetr.io/res/skins/minos/connected.png
  // block size: 48x48, connected textures use 4x6 variants
  for (let block = 0; block < 10; block++) {
    ctx.save();
    let rowsToCopy = 6;
    switch (true) {
      case block < 4: ctx.translate(block*48*f*4, 0); break;
      case block < 8: ctx.translate((block-4)*48*f*4, 48*f*6); break;
      case block == 8: ctx.translate(4*48*f*4, 0); rowsToCopy = 4; break;
      case block == 9: ctx.translate(4*48*f*4, 48*f*4); rowsToCopy = 4; break;
    }
    for (let dx = 0; dx < 4; dx++) {
      for (let dy = 0; dy < rowsToCopy; dy++) {
        let src_x = (block % srcColumns) * srcBlockSize;
        let src_y = Math.floor(block / srcColumns) * srcBlockSize;
        let src_w = srcBlockSize;
        let src_h = srcBlockSize;
        let dest_x = 48*f * dx;
        let dest_y = 48*f * dy;
        let dest_w = 48*f;
        let dest_h = 48*f;
        ctx.drawImage(image,src_x,src_y,src_w,src_h,dest_x,dest_y,dest_w,dest_h);
      }
    }
    ctx.restore();
  }

  return canvas;
}
