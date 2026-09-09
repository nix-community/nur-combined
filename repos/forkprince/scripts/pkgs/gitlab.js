const { guard } = require("./safe");

function getToken(instance) {
  const hostname = new URL(instance).hostname;

  const env = `${hostname.toUpperCase().replace(/[^A-Z0-9]/g, "")}_TOKEN`;

  return process.env[env];
}

async function getReleases(instance, repo, skip = false) {
  const project = encodeURIComponent(repo);

  const url = skip
    ? `${instance}/api/v4/projects/${project}/releases?per_page=1`
    : `${instance}/api/v4/projects/${project}/releases`;

  const token = getToken(instance);

  const releases = await (await fetch(url, {
    headers: token && {
      Authorization: `Bearer ${token}`
    }
  })).json();

  return Array.isArray(releases) ? releases : [releases];
}

async function check(file, { config, force, repo = null }) {
  const instance = config.source.instance;
  const api_repo = repo || config.source.repo;

  let releases = (await getReleases(instance, api_repo)).sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());

  if (config.source.skip_prerelease) releases = releases.filter(release => !release.upcoming_release);

  if (config.source.tag_filter) {
    const filter = new RegExp(config.source.tag_filter);

    releases = releases.filter(release => filter.test(release.tag_name));
    if (!releases?.length) throw new Error(`No releases found matching filter: ${config.source.tag_filter}`);
  }

  const version = config.source.query ? await guard(q => eval(`(${JSON.stringify(releases)})${q}`), undefined)(config.source.query) : releases[0].tag_name;
  if (!version) throw new Error("Failed to extract version from GitLab releases");

  const prefix = config.source.tag_prefix || "";
  const parsed = prefix ? version.replace(new RegExp(`^${prefix.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}`), "") : version.replace(/^v/, "");

  console.log(`Latest version: ${parsed}`);

  if (!force && parsed === config.version) return { releases: "", version: "" };

  console.log(`Update: ${config.version} → ${parsed}`);

  return { releases, version: parsed };
}

module.exports = {
  getReleases,
  check
}
