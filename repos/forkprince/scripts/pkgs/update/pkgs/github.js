const { getReleases } = require("../../github");
const { apply } = require("../../text");
const getHash = require("../../hash");
const update = require("../../file");

async function check(file, { config, force }) {
    let api_repo = config.source.repo;

    if (config.platforms) {
        const platforms = config.platforms || {};

        const first = Object.values(platforms)[0];

        api_repo = first?.substitutions ? apply(config.source.repo, first.substitutions) : api_repo;
    }

    if (config.variants) {
        const variants = config.variants || {};

        const first = Object.values(variants)[0];

        api_repo = first?.substitutions ? apply(config.source.repo, first.substitutions) : api_repo;
    }

    const releases = (await getReleases(api_repo)).sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());

    const version = eval(`(${JSON.stringify(releases)})${config.source.query}`);
    if (!version) throw new Error("Failed to extract version from GitHub releases");

    const parsed = version.replace(/^v/, "");

    console.log(`Latest version: ${parsed}`);

    if (!force && parsed === config.version) return { releases: "", version: "" };

    console.log(`Update: ${config.version} → ${parsed}`);

    return { releases, version: parsed };
}

async function single(file, { config, force }) {
    const { version } = await check(file, { config, force });
    if (!version) return;

    const prefix = config.source.tag_prefix || "";
    const repo = config.source.repo;

    let url = config.asset.file ? `https://github.com/${repo}/releases/download/${prefix}${version}/${config.asset.file}` : config.asset.url

    url = url
        .replace(/\{repo\}/g, repo)
        .replace(/\{version\}/g, version)
        .replace(/\{raw_version\}/g, `${prefix}${version}`);

    console.log(`Downloading ${url}`);

    const hash = await getHash(url);

    await update.single(file, { version, hash });

    console.log(`Updated to version ${version}`);
}

async function platforms(file, { config, force }) {
    const { version } = await check(file, { config, force });
    if (!version) return;

    const platforms = config.platforms || {};

    for (const [platform, settings] of Object.entries(platforms)) {
        const repo = settings.repo || config.source.repo;

        const prefix = settings.tag_prefix || config.source.tag_prefix || "";
        const unpack = settings.unpack || false;

        let url = settings.file ? `https://github.com/${repo}/releases/download/${prefix}${version}/${settings.file}` : settings.url;

        url = url
            .replace(/\{repo\}/g, repo)
            .replace(/\{version\}/g, version)
            .replace(/\{raw_version\}/g, `${prefix}${version}`);

        console.log(`Downloading ${url} (${platform})`);

        const hash = await getHash(url, unpack);

        await update.platforms(file, { platform, url: settings.url ? url : undefined, hash });

        console.log(`Updated ${platform} to version ${version}`);
    }

    await update.single(file, { version });

    console.log(`Updated ${Object.keys(platforms).length} platforms to version ${version}`);
}

async function variants(file, { config, force }) {
    const { version } = await check(file, { config, force });
    if (!version) return;

    const variants = config.variants || {};

    for (const [variant, settings] of Object.entries(variants)) {
        const repo = settings.repo || config.source.repo;

        const prefix = settings.tag_prefix || config.source.tag_prefix || "";
        const unpack = settings.unpack || config.asset.unpack || false;
        const file_name = settings.file || config.asset.file;

        const name = apply(file_name.replace(/\{version\}/g, version), settings.substitutions);

        const url = `https://github.com/${repo}/releases/download/${prefix}${version}/${name}`;

        console.log(`Downloading ${url} (${variant})`);

        const hash = await getHash(url, unpack);

        await update.variants(file, { variant, hash });

        console.log(`Updated ${variant} to version ${version}`);
    }

    await update.single(file, { version });

    console.log(`Updated ${Object.keys(variants).length} variants to version ${version}`);
}

module.exports = {
    single,
    platforms,
    variants
}