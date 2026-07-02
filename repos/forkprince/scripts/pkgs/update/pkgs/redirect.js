const getHash = require("../../hash");
const update = require("../../file");

async function single(file, { config, force }) {
  const redirect = config.source.redirect_url;
  if (!redirect) throw new Error("No redirect_url specified in source config");

  const regex = config.source.version_regex ? new RegExp(config.source.version_regex) : null;

  console.log(`Fetching ${redirect}...`);

  const response = await fetch(redirect);
  if (!response.ok) throw new Error(`Failed to fetch ${redirect}: ${response.status}`);

  const final = response.url;
  console.log(`Redirected to ${final}`);

  if (!force && final === config.asset?.url) return;

  if (!regex) throw new Error("No version_regex configured in source config");

  const match = final.match(regex);
  if (!match?.[1]) throw new Error(`Failed to extract version from URL ${final} using regex ${config.source.version_regex}`);

  version = match[1];

  console.log(`Extracted version: ${version}`);

  if (!force && version === config.version) return;

  console.log(`Update: ${config.version || "none"} → ${version}`);

  console.log(`Downloading ${final}...`);
  const hash = await getHash(final);

  await update.single(file, { version, asset: { url: final, hash } });

  console.log(`Updated to version ${version}`);
}

async function platforms(file, { config, force }) {
  const platforms = config.platforms || {};
  const regex = config.source.version_regex ? new RegExp(config.source.version_regex) : null;

  let updated = 0, common = null;

  for (const [platform, settings] of Object.entries(platforms)) {
    if (settings.locked && !force) {
      console.log(`Skipping ${platform} because it is locked.`);
      continue;
    }

    const redirect = settings.redirect_url;
    if (!redirect) {
      console.log(`Skipping ${platform} because it has no redirect_url.`);
      continue;
    }

    console.log(`Fetching ${redirect} (${platform})...`);

    const response = await fetch(redirect);
    if (!response.ok) {
      console.error(`Failed to fetch ${redirect}: ${response.status} ${response.statusText}`);
      continue;
    }

    const final = response.url;
    console.log(`Redirected to ${final}`);

    if (!force && final === settings.url) {
      console.log(`No update for ${platform} (URL unchanged)`);
      continue;
    }

    console.log(`Update ${platform}: ${settings.url || "none"} → ${final}`);

    let version;
    if (regex) {
      const match = final.match(regex);
      if (!match?.[1]) {
        console.error(`Failed to extract version from URL using regex ${config.source.version_regex}`);
        continue;
      }

      version = match[1];
    } else if (config.version) {
      version = config.version;
      console.log(`No version_regex configured; keeping current version ${version}`);
    } else {
      console.error("No version_regex configured and no existing version");
      continue;
    }

    if (!common) common = version;

    console.log(`Downloading ${final} (${platform})...`);
    const hash = await getHash(final);

    await update.platforms(file, { platform, url: final, hash });

    console.log(`Updated ${platform} to version ${version}`);
    updated++;
  }

  if (updated > 0 && common) {
    await update.single(file, { version: common });
    console.log(`Updated ${updated} platforms to version ${common}`);
  }
}

module.exports = {
  single,
  platforms
};
