async function read(file) {
  return await (Bun.file(file)).json();
}

async function save(file, data) {
  return Bun.write(file, JSON.stringify(data, null, 2));
}

async function single(file, data) {
  const content = await read(file);

  await save(file, { ...content, ...data });
}

async function platforms(file, { platform, url, hash, version }) {
  const content = await read(file);

  const platforms = content.platforms || {};

  if (version) platforms[platform].version = version;
  if (url) platforms[platform].url = url;

  platforms[platform].hash = hash;

  await save(file, { ...content, platforms });
}

async function variants(file, { variant, hash }) {
  const content = await read(file);

  const variants = content.variants || {};

  variants[variant].hash = hash;

  await save(file, { ...content, variants });
}

module.exports = {
  read,
  save,
  single,
  platforms,
  variants
}
