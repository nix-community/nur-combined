const { getReleases } = require("../../github");
const { apply } = require("../../text");
const getHash = require("../../hash");
const update = require("../../file");

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

    const releases = (await getReleases(api_repo, config.source.skipPrerelease)).sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());

    const version = config.source.skipPrerelease ? releases[0].tag_name : eval(`(${JSON.stringify(releases)})${config.source.query}`);
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

    const unpack = config.asset.unpack || false;

    let url = config.asset.file ? `https://github.com/${repo}/releases/download/${prefix}${version}/${config.asset.file}` : config.asset.url

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

    const hasVersions = Object.values(platforms).some(p => p.version !== undefined);
    if (!hasVersions) {
        const { version } = await check(file, { config, force });
        if (!version) return;

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
    } else {
        let updated = 0;

        for (const [platform, settings] of Object.entries(platforms)) {
            const repo = settings.repo || config.source.repo;

            console.log(`Checking ${platform} (${repo})...`);

            const releases = (await getReleases(repo, config.source.skipPrerelease)).sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());

            const version = config.source.skipPrerelease 
                ? releases[0].tag_name
                : eval(`(${JSON.stringify(releases)})${config.source.query}`);
            if (!version) continue;

            const parsed = version.replace(/^v/, "");

            console.log(`Latest version for ${platform}: ${parsed}`);

            if (!force && parsed === settings.version) continue

            console.log(`Update ${platform}: ${settings.version} → ${parsed}`);

            const prefix = settings.tag_prefix || config.source.tag_prefix || "";
            const unpack = settings.unpack || false;

            let url = settings.file ? `https://github.com/${repo}/releases/download/${prefix}${parsed}/${settings.file}` : settings.url;

            url = url
                .replace(/\{repo\}/g, repo)
                .replace(/\{version\}/g, parsed)
                .replace(/\{raw_version\}/g, `${prefix}${parsed}`);

            console.log(`Downloading ${url}`);

            const hash = await getHash(url, unpack);

            await update.platforms(file, { platform, url: settings.url ? url : undefined, hash, version: parsed });

            console.log(`Updated ${platform} to version ${parsed}`);

            updated++;
        }

        console.log(`Updated ${updated} platforms`);
    }
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