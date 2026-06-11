const sampleRate = 44100;
const channels = 2;
const quality = 0.5;
export default async function encode(sprites, storage, options) {
  let encoder = new window.OggVorbisEncoder(sampleRate, channels, quality);

  let atlas = {};
  let currentOffset = 0;
  for (let { name, buffer } of sprites) {
    (options&&options.log||(()=>{}))('buffer', name, buffer.duration, '@', buffer.sampleRate);
    let duration = buffer.duration * 1000;
    let offset = currentOffset;
    currentOffset += duration;

    atlas[name] = [offset, duration];
    encoder.encode([
      buffer.getChannelData(0),
      buffer.numberOfChannels >= 2
        ? buffer.getChannelData(1) // use 2nd channel if stereo
        : buffer.getChannelData(0) // duplicate 1st channel if mono
    ]);
  }


  let blob = encoder.finish();
  // require('fs').writeFileSync('debug.ogg.wav', Buffer.from(await new Promise(res => {
  //   let blobReader = new window.FileReader();
  //   blobReader.onload = evt => res(blobReader.result)
  //   blobReader.readAsArrayBuffer(blob);
  // })));
  let dataUrl = await new Promise(async res => {
    if (window.IS_NODEJS_POLYFILLED) {
      res('data:audio/ogg;base64,' + Buffer.from(await blob.arrayBuffer()).toString('base64'));
    } else {
      let blobReader = new window.FileReader();
      blobReader.onload = evt => res(blobReader.result)
      blobReader.readAsDataURL(blob);
    }
  });

  storage.set({
    customSounds: dataUrl,
    customSoundAtlas: atlas
  });

  return dataUrl;
}
