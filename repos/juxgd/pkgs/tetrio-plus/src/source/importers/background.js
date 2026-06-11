let keys = ['_bg', '_vbg'];

export async function test(files) {
  return files.every(file => {
    return (
      /^(image|video)/.test(file.type) &&
      keys.some(key => file.name.includes(key))
    );
  });
}

export async function load(files, storage) {
  for (let file of files) {
    if (file.name.includes('_vbg')) {
      await loadIndividual(file, 'video', storage);
    } else if (file.name.includes('_bg')) {
      await loadIndividual(file, 'image', storage);
    } else if (/^video/.test(file.type)) {
      await loadIndividual(file, 'video', storage);
    } else {
      await loadIndividual(file, 'image', storage);
    }
  }
  return { type: 'backgrounds' };
}

export function randomId() {
  return new Array(16).fill(0).map(e =>
    String.fromCharCode(97 + Math.floor(Math.random() * 26))
  ).join('');
}
export async function loadIndividual(file, type, storage) {
  let backgrounds = (await storage.get('backgrounds')).backgrounds || [];
  let id = randomId();
  backgrounds.push({ id, type, filename: file.name });
  await storage.set({
    backgrounds: backgrounds,
    ['background-' + id]: file.data
  });
}
