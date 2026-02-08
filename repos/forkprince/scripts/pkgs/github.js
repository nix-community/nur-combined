async function getURL(url) {
  return fetch(url, {
    headers: process.env.GITHUB_TOKEN && {
      Authorization: `token ${process.env.GITHUB_TOKEN}`,
    }
  });
}

async function getReleases(repo, skip = false) {
  const url = skip ? `https://api.github.com/repos/${repo}/releases/latest` : `https://api.github.com/repos/${repo}/releases`;

  const releases = await (await getURL(url)).json();

  return skip ? [releases] : releases;
}

async function check(file, { config, force, repo = null }) {
  const api_repo = repo || config.source.repo;

  let releases = (await getReleases(api_repo, config.source.skipPrerelease)).sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());

  if (config.source.tag_filter) {
    const filter = new RegExp(config.source.tag_filter);

    releases = releases.filter(release => filter.test(release.tag_name));
    if (!releases?.length) throw new Error(`No releases found matching filter: ${config.source.tag_filter}`);
  }

  const version = (config.source.skipPrerelease || !config.source.query) ? releases[0].tag_name : eval(`(${JSON.stringify(releases)})${config.source.query}`);
  if (!version) throw new Error("Failed to extract version from GitHub releases");

  const parsed = version.replace(/^v/, "");

  console.log(`Latest version: ${parsed}`);

  if (!force && parsed === config.version) return { releases: "", version: "" };

  console.log(`Update: ${config.version} → ${parsed}`);

  return { releases, version: parsed };
}

module.exports = {
  getReleases,
  getURL,
  check
}
