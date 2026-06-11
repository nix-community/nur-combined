export default async function splitgif(file, options) {
  const gif = window.GIFGroover();
  gif.playOnLoad = false;
  gif.src = file.data;
  let evt = await new Promise(res => gif.onload = res);

  if (options.delay == 0) {
    let fps = ((gif.duration / gif.frameCount) / 1000) * 60;
    options.delay = fps;
  }

  let canvas = window.document.createElement('canvas');
  canvas.width = gif.naturalWidth;
  canvas.height = gif.naturalHeight;
  let ctx = canvas.getContext('2d');

  let frames = [];
  for (let i = 0; i < gif.frameCount; i++) {
    if (!options.combine)
      ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.drawImage(gif.getFrame(i), 0, 0);

    let image = window.document.createElement('canvas');
    image.width = canvas.width;
    image.height = canvas.height;
    image.getContext('2d').drawImage(canvas, 0, 0);
    let data = image.toDataURL('image/png');
    frames.push({ ...file, type: 'image/png', image, data });
  }
  return frames;
}
