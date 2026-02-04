const { apply } = require("../../text");
const getHash = require("../../hash");
const update = require("../../file");

async function single(file, { config, force }) {
  const api = await (await fetch(config.source.url)).json();

  const raw = JSON.stringify(api);

  const version = eval(`(${raw})${config.source.version_path}`);
  if (!version) throw new Error("Failed to extract version from API response");

  const parsed = version.replace(/^v/, "");

  console.log(`Latest version: ${parsed}`);

  if (!force && parsed === config.version) return;

  console.log(`Update: ${config.version} → ${parsed}`);

  const url = eval(`(${raw})${config.source.url_path}`);
  if (!url) throw new Error("Failed to extract URL from API response");

  console.log(`Downloading ${url}`);

  const hash = await getHash(url);

  await update.single(file, { version: parsed, asset: { ...config.asset, url, hash } });

  console.log(`Updated to version ${parsed}`);
}

async function platforms(file, { config, force }) {
  const platforms = config.platforms || {};

  const first = Object.values(platforms)[0];

  const api_url = first?.substitutions ? apply(config.source.url, first.substitutions) : config.source.url;

  const api = await (await fetch(api_url)).json();
  const raw = JSON.stringify(api);

  const version = eval(`(${raw})${config.source.version_path}`);
  if (!version) throw new Error("Failed to extract version from API response");

  const parsed = version.replace(/^v/, "");

  console.log(`Latest version: ${parsed}`);

  if (!force && parsed === config.version) return;

  console.log(`Update: ${config.version} → ${parsed}`);

  for (const [platform, settings] of Object.entries(platforms)) {
    let final;

    if (!config.source.url_path) final = apply(settings.url.replace(/\{version\}/g, parsed), settings.substitutions);
    else {
      let link = apply(config.source.url, settings.substitutions);

      const api = await (await fetch(link)).json();

      const url = apply(config.source.url_path, settings.substitutions);

      link = eval(`(${JSON.stringify(api)})${url}`);

      final = link;
    }

    if (!final) throw new Error("Failed to extract URL from API response");

    console.log(`Downloading ${final} (${platform})`);

    const hash = await getHash(final);

    await update.platforms(file, { platform, url: final, hash });

    console.log(`Updated ${platform} to version ${parsed}`);
  }

  await update.single(file, { version: parsed });

  console.log(`Updated ${Object.keys(platforms).length} platforms to version ${parsed}`);
}

module.exports = {
  single,
  platforms
}
