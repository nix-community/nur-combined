export default function(image) {
  const canvas = window.document.createElement('canvas');
  const pixelGapConstant = 31/30;
  canvas.width = image.width * 12 / 9 * pixelGapConstant;
  canvas.height = image.height;
  const ctx = canvas.getContext('2d');

  // Jstris format: Garbage, Ghost, ROYGBIV
  // Tetrio format: ROYGBIV, Ghost, Garbage, Garbage 2, Dark garbage, Top-out warning
  const shuffle = [2, 3, 4, 5, 6, 7, 8, 1, 0, 0, 0, 0];
  const step = image.height;
  for (let i = 0; i < 12; i++) {
    ctx.drawImage(
      image,
      shuffle[i]*step, 0, step, step,
      i*(step * pixelGapConstant), 0, step, step
    )
  }

  return canvas;
}
