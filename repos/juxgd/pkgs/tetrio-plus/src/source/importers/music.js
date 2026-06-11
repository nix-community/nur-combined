export async function test(files) {
  return files.every(file => /^audio/.test(file.type));
}

export async function load(files, storage) {
  throw new Error('TODO');
}
