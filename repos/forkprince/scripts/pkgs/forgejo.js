async function getReleases(instance, repo, skip = false) {
  const url = skip
    ? `${instance}/api/v1/repos/${repo}/releases?pre-release=false`
    : `${instance}/api/v1/repos/${repo}/releases`;

  const releases = await (await fetch(url)).json();

  return skip ? [releases[0]] : releases;
}

module.exports = {
  getReleases
}
