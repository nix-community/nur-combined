createRewriteFilter("Sfx Request", "https://tetr.io/sfx/tetrio.opus.rsd*", {
  enabledFor: async (storage, request) => {
    let {sfxEnabled} = await storage.get('sfxEnabled');
    if (!sfxEnabled) return false; // Custom sfx disabled

    let {customSoundAtlas} = await storage.get('customSoundAtlas');
    if (!customSoundAtlas) return false; // No custom sfx configured

    return true;
  },
  onStart: async (storage, url, src, callback) => {
    let { customSounds, customSoundAtlas } = await storage.get(['customSounds', 'customSoundAtlas']);
    
    // Note: the new audio format introduced in TETR.IO β1.6.2 no longer uses the duration field and instead assumes tight packing,
    // with the duration of each sprite inferred by the distance to the offset of the next sprite.
    // TETR.IO PLUS already does tight packing, so this approach should be fine.
    
    let atlas = Object.entries(customSoundAtlas).map(([name, [offset, duration]]) => ({ name, offset, duration }));
    atlas.sort((a, b) => {
      if (a.offset < b.offset) return -1;
      if (a.offset > b.offset) return 1;
      return 0;
    });
    
    let temp_buffer = new ArrayBuffer(4);
    let view = new DataView(temp_buffer);
    
    let header_buffer = [];
    header_buffer.push(0x74, 0x52, 0x53, 0x44); // header
    view.setUint32(0, 1, true); // major
    header_buffer.push(...new Uint8Array(temp_buffer)); 
    view.setUint32(0, 0, true); // minor
    header_buffer.push(...new Uint8Array(temp_buffer));
    for (let { name, offset, duration } of atlas) {
      let name_buffer = new TextEncoder().encode(name);
      
      // atlas values are in milliseconds, but tetrio changed to using seconds with its new format
      view.setFloat32(0, offset/1000, true);
      header_buffer.push(...new Uint8Array(temp_buffer));
      
      view.setUint32(0, name_buffer.length, true);
      header_buffer.push(...new Uint8Array(temp_buffer));
      
      header_buffer.push(...name_buffer);
    }
    
    let last_sprite = atlas[atlas.length-1];
    view.setFloat32(0, (last_sprite.offset + last_sprite.duration)/1000, true);
    header_buffer.push(...new Uint8Array(temp_buffer));
    header_buffer.push(0, 0, 0, 0); // name length of last sprite
    
    let audio_buffer = convertDataURIToBinary(customSounds);
    view.setUint32(0, audio_buffer.byteLength, true);
    header_buffer.push(...new Uint8Array(temp_buffer));
    
    let final_buffer = new Uint8Array(header_buffer.length + audio_buffer.length);
    final_buffer.set(header_buffer, 0);
    final_buffer.set(audio_buffer, header_buffer.length);
    
    callback({
      type: 'audio/ogg',
      data: final_buffer,
      encoding: 'arraybuffer'
    });
  }
});


// https://gist.github.com/borismus/1032746
var BASE64_MARKER = ';base64,';
function convertDataURIToBinary(dataURI) {
  var base64Index = dataURI.indexOf(BASE64_MARKER) + BASE64_MARKER.length;
  var base64 = dataURI.substring(base64Index);
  if (typeof Buffer !== 'undefined') {
    return Uint8Array.from(Buffer.from(base64, 'base64')); // electron main process nodejs (too old for fromBase64)
  } else {
    return Uint8Array.fromBase64(base64); // browser
  }
}
