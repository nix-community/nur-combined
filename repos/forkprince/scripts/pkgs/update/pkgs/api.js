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

  let url, template = false;

  if (config.source.url_path) {
    url = eval(`(${raw})${config.source.url_path}`);
    if (!url) throw new Error("Failed to extract URL from API response");
  } else if (config.asset?.url) {
    url = config.asset.url.replace(/\{version\}/g, parsed);
    template = true;
  } else throw new Error("Failed to extract URL from API response");

  console.log(`Downloading ${url}`);

  const hash = await getHash(url);

  const asset = template ? { ...config.asset, hash } : { ...config.asset, url, hash };

  await update.single(file, { version: parsed, asset });

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

  let updated = 0;
  for (const [platform, settings] of Object.entries(platforms)) {
    if (settings.locked && !force) {
      console.log(`Skipping ${platform} because it is locked.`);
      continue;
    }

    let download, template = false;

    const url_path = settings.url_path || config.source.url_path;

    if (!url_path) {
      download = apply(settings.url.replace(/\{version\}/g, parsed), settings.substitutions);
      template = true;
    } else {
      let link = apply(config.source.url, settings.substitutions);

      const api = await (await fetch(link)).json();

      const url = apply(url_path, settings.substitutions);

      link = eval(`(${JSON.stringify(api)})${url}`);

      download = link;
    }

    if (!download) throw new Error("Failed to extract URL from API response");

    console.log(`Downloading ${download} (${platform})`);

    const hash = await getHash(download);

    await update.platforms(file, {
      platform,
      url: template ? undefined : download,
      hash
    });

    console.log(`Updated ${platform} to version ${parsed}`);

    updated++;
  }

  if (updated > 0) {
    await update.single(file, { version: parsed });
    console.log(`Updated ${updated} platforms to version ${parsed}`);
  }
}

module.exports = {
  single,
  platforms
}
