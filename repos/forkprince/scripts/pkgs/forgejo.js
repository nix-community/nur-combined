function getToken(instance) {
  const hostname = new URL(instance).hostname;

  const env = `${hostname.toUpperCase().replace(/[^A-Z0-9]/g, "")}_TOKEN`;

  return process.env[env];
}

async function getReleases(instance, repo, skip = false) {
  const url = skip
    ? `${instance}/api/v1/repos/${repo}/releases?pre-release=false`
    : `${instance}/api/v1/repos/${repo}/releases`;

  const token = getToken(instance);

  const releases = await (await fetch(url, {
    headers: token && {
      Authorization: `Bearer ${token}`
    }
  })).json();

  return skip ? [releases[0]] : releases;
}

module.exports = {
  getReleases
}
