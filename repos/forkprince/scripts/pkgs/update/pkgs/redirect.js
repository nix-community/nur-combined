const getHash = require("../../hash");
const update = require("../../file");

async function single(file, { config, force }) {
  const redirectUrl = config.source.redirect_url;
  if (!redirectUrl) throw new Error("No redirect_url specified in source config");

  const versionRegex = config.source.version_regex ? new RegExp(config.source.version_regex) : null;

  console.log(`Fetching ${redirectUrl}...`);

  const response = await fetch(redirectUrl);
  if (!response.ok) throw new Error(`Failed to fetch ${redirectUrl}: ${response.status}`);

  const finalUrl = response.url;
  console.log(`Redirected to ${finalUrl}`);

  if (!force && finalUrl === config.asset?.url) return;

  let version;
  if (versionRegex) {
    const match = finalUrl.match(versionRegex);
    if (match?.[1]) {
      version = match[1];
    } else {
      throw new Error(`Failed to extract version from URL ${finalUrl} using regex ${config.source.version_regex}`);
    }
  } else {
    throw new Error("No version_regex configured in source config");
  }

  console.log(`Extracted version: ${version}`);

  if (!force && version === config.version) return;

  console.log(`Update: ${config.version || "none"} → ${version}`);

  console.log(`Downloading ${finalUrl}...`);
  const hash = await getHash(finalUrl);

  await update.single(file, { version, asset: { url: finalUrl, hash } });

  console.log(`Updated to version ${version}`);
}

async function platforms(file, { config, force }) {
  const platforms = config.platforms || {};
  const versionRegex = config.source.version_regex ? new RegExp(config.source.version_regex) : null;

  let updated = 0;
  let commonVersion = null;

  for (const [platform, settings] of Object.entries(platforms)) {
    if (settings.locked && !force) {
      console.log(`Skipping ${platform} because it is locked.`);
      continue;
    }

    const redirectUrl = settings.redirect_url;
    if (!redirectUrl) {
      console.log(`Skipping ${platform} because it has no redirect_url.`);
      continue;
    }

    console.log(`Fetching ${redirectUrl} (${platform})...`);

    const response = await fetch(redirectUrl);
    if (!response.ok) {
      console.error(`Failed to fetch ${redirectUrl}: ${response.status} ${response.statusText}`);
      continue;
    }

    const finalUrl = response.url;
    console.log(`Redirected to ${finalUrl}`);

    if (!force && finalUrl === settings.url) {
      console.log(`No update for ${platform} (URL unchanged)`);
      continue;
    }

    const oldUrl = settings.url || "none";
    console.log(`Update ${platform}: ${oldUrl} → ${finalUrl}`);

    let version;
    if (versionRegex) {
      const match = finalUrl.match(versionRegex);
      if (match?.[1]) {
        version = match[1];
      } else {
        console.error(`Failed to extract version from URL using regex ${config.source.version_regex}`);
        continue;
      }
    } else {
      if (config.version) {
        version = config.version;
        console.log(`No version_regex configured; keeping current version ${version}`);
      } else {
        console.error("No version_regex configured and no existing version");
        continue;
      }
    }

    if (!commonVersion) commonVersion = version;

    console.log(`Downloading ${finalUrl} (${platform})...`);
    const hash = await getHash(finalUrl);

    await update.platforms(file, { platform, url: finalUrl, hash });

    console.log(`Updated ${platform} to version ${version}`);
    updated++;
  }

  if (updated > 0 && commonVersion) {
    await update.single(file, { version: commonVersion });
    console.log(`Updated ${updated} platforms to version ${commonVersion}`);
  }
}

module.exports = {
  single,
  platforms
};
