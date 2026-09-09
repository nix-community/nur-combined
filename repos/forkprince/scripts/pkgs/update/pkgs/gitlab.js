const { getReleases, check: checkVersion } = require("../../gitlab");
const { guard } = require("../../safe");
const { apply } = require("../../text");
const getHash = require("../../hash");
const update = require("../../file");

function findUrl(release, fileName) {
  if (!release?.assets?.links) return null;

  const link = release.assets.links.find(l => l.name === fileName);
  return link?.url || null;
}

async function check(file, { config, force }) {
  let api_repo = config.source.repo;

  if (config.platforms) {
    const platforms = config.platforms || {};

    const first = Object.values(platforms)[0];
    const repo = first?.repo || config.source.repo;

    api_repo = first?.substitutions ? apply(repo, first.substitutions) : repo;
  }

  if (config.variants) {
    const variants = config.variants || {};

    const first = Object.values(variants)[0];

    api_repo = first?.substitutions ? apply(config.source.repo, first.substitutions) : api_repo;
  }

  return await checkVersion(file, { config, force, repo: api_repo });
}

async function single(file, { config, force }) {
  const { releases, version } = await check(file, { config, force });
  if (!version) return;

  const prefix = config.source.tag_prefix || "";
  const repo = config.source.repo;
  const instance = config.source.instance;

  const unpack = config.asset.unpack || false;

  let url;

  if (config.asset.file) {
    const release = releases.find(r => r.tag_name === `${prefix}${version}` || r.tag_name === version);
    const fileName = apply(config.asset.file.replace(/\{version\}/g, version), []);

    url = findUrl(release, fileName);
    if (!url) url = `${instance}/${repo}/releases/download/${prefix}${version}/${fileName}`;
  } else url = config.asset.url;

  url = url
    .replace(/\{repo\}/g, repo)
    .replace(/\{version\}/g, version)
    .replace(/\{raw_version\}/g, `${prefix}${version}`);

  console.log(`Downloading ${url}`);

  const hash = await getHash(url, unpack);

  await update.single(file, { version, hash });

  console.log(`Updated to version ${version}`);
}

async function platforms(file, { config, force }) {
  const platforms = config.platforms || {};

  let updated = 0;

  const hasVersions = Object.values(platforms).some(p => p.version !== undefined);
  if (!hasVersions) {
    const { releases, version } = await check(file, { config, force });
    if (!version) return;

    const release = releases.find(r => r.tag_name === `${config.source.tag_prefix || ""}${version}`) || releases[0];

    for (const [platform, settings] of Object.entries(platforms)) {
      if (settings.locked && !force) {
        console.log(`Skipping ${platform} because it is locked.`);
        continue;
      }

      const prefix = settings.tag_prefix || config.source.tag_prefix || "";
      const unpack = settings.unpack || false;
      const repo = settings.repo || config.source.repo;
      const instance = settings.instance || config.source.instance;
      const fileName = settings.file ? apply(settings.file.replace(/\{version\}/g, version), settings.substitutions || []) : null;

      let url;

      if (fileName && release) url = findUrl(release, fileName);

      if (!url) url = settings.file
        ? `${instance}/${repo}/releases/download/${prefix}${version}/${fileName}`
        : settings.url;

      url = url
        .replace(/\{repo\}/g, repo)
        .replace(/\{version\}/g, version)
        .replace(/\{raw_version\}/g, `${prefix}${version}`);

      console.log(`Downloading ${url} (${platform})`);

      const hash = await getHash(url, unpack);

      await update.platforms(file, { platform, url: settings.url ? url : undefined, hash });

      console.log(`Updated ${platform} to version ${version}`);

      updated++;
    }

    if (updated > 0) {
      await update.single(file, { version });
      console.log(`Updated ${updated} platforms to version ${version}`);
    }
  } else {
    for (const [platform, settings] of Object.entries(platforms)) {
      if (settings.locked && !force) {
        console.log(`Skipping ${platform} because it is locked.`);
        continue;
      }

      const repo = settings.repo || config.source.repo;
      const instance = settings.instance || config.source.instance;

      console.log(`Checking ${platform} (${repo})...`);

      let releases = (await getReleases(instance, repo)).sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());

      if (config.source.skip_prerelease) releases = releases.filter(release => !release.upcoming_release);

      if (config.source.tag_filter) {
        const filter = new RegExp(config.source.tag_filter);

        releases = releases.filter(release => filter.test(release.tag_name));
        if (releases.length === 0) {
          console.log(`Skipping ${platform}: no releases match tag_filter`);
          continue;
        }
      }

      const version = config.source.query ? await guard(q => eval(`(${JSON.stringify(releases)})${q}`), undefined)(config.source.query) : releases[0].tag_name;
      if (!version) continue;

      const parsed = version.replace(/^v/, "");

      console.log(`Latest version for ${platform}: ${parsed}`);

      if (!force && parsed === settings.version) continue

      console.log(`Update ${platform}: ${settings.version} → ${parsed}`);

      const prefix = settings.tag_prefix || config.source.tag_prefix || "";
      const unpack = settings.unpack || false;
      const release = releases.find(r => r.tag_name === version) || releases[0];

      const resolved = settings.query ? await guard(q => eval(`(${JSON.stringify(releases)})${q}`), undefined)(settings.query) : settings.file;
      if (!resolved && !settings.url) {
        console.log(`Skipping ${platform}: no matching asset found for version ${parsed}`);
        continue;
      }

      let url;

      if (resolved) {
        const fileName = apply(resolved.replace(/\{version\}/g, parsed), settings.substitutions || []);

        url = release ? findUrl(release, fileName) : null;
        if (!url) url = `${instance}/${repo}/releases/download/${prefix}${parsed}/${fileName}`;
      } else url = settings.url;

      url = url
        .replace(/\{repo\}/g, repo)
        .replace(/\{version\}/g, parsed)
        .replace(/\{raw_version\}/g, `${prefix}${parsed}`);

      console.log(`Downloading ${url}`);

      const hash = await getHash(url, unpack);

      await update.platforms(file, { platform, url: settings.url ? url : undefined, hash, version: parsed, file: settings.query ? resolved : undefined });

      console.log(`Updated ${platform} to version ${parsed}`);

      updated++;
    }

    console.log(`Updated ${updated} platforms`);
  }
}

async function variants(file, { config, force }) {
  const { releases, version } = await check(file, { config, force });
  if (!version) return;

  const variants = config.variants || {};
  const instance = config.source.instance;
  const prefix = config.source.tag_prefix || "";
  const release = releases.find(r => r.tag_name === `${prefix}${version}`) || releases[0];

  let updated = 0;
  for (const [variant, settings] of Object.entries(variants)) {
    if (settings.locked && !force) {
      console.log(`Skipping ${variant} because it is locked.`);
      continue;
    }

    const repo = settings.repo || config.source.repo;

    const unpack = settings.unpack || config.asset.unpack || false;
    const file_name = settings.file || config.asset.file;

    const name = apply(file_name.replace(/\{version\}/g, version), settings.substitutions);

    let url = release ? findUrl(release, name) : null;
    if (!url) url = `${instance}/${repo}/releases/download/${prefix}${version}/${name}`;

    console.log(`Downloading ${url} (${variant})`);

    const hash = await getHash(url, unpack);

    await update.variants(file, { variant, hash });

    console.log(`Updated ${variant} to version ${version}`);

    updated++;
  }

  if (updated > 0) {
    await update.single(file, { version });
    console.log(`Updated ${updated} variants to version ${version}`);
  }
}

module.exports = {
  single,
  platforms,
  variants
}
