import * as fs from "node:fs/promises";
import { github, nix, semver } from "nix-repin";

const owner = "klzgrad";
const repo = "forwardproxy";

const fetchzip = (archive: github.ArchiveSource) =>
  `fetchzip {
    url = ${nix.string(archive.url)};
    hash = ${nix.string(archive.hash)};
    extension = "tar.gz";
  }`;

// The fork's go.mod keeps the module path without /v2, so Go refuses its v2 tags as versions; xcaddy gets the naive tag's commit as a pseudo-version instead.
// Each tag also carries the Caddy patches its release builds apply, and names that Caddy release in CADDY_VERSION.
export default async () => {
  const tags = await github.octokit.paginate(
    github.octokit.rest.repos.listTags,
    {
      owner,
      repo,
      per_page: 100,
    },
  );
  const [latest] = tags
    .filter((tag) => /^v\d+\.\d+\.\d+-naive\d*$/.test(tag.name))
    .sort((a, b) => semver.compare(b.name.slice(1), a.name.slice(1)));
  if (!latest) {
    throw new Error(`${owner}/${repo}: no naive tag found`);
  }

  const { data: commit } = await github.octokit.rest.repos.getCommit({
    owner,
    repo,
    ref: latest.commit.sha,
  });
  // Go stamps a pseudo-version with the commit time in UTC, down to the second.
  const time = commit.commit.committer!.date!.replace(/\D/g, "").slice(0, 14);
  const goVersion = `v0.0.0-${time}-${latest.commit.sha.slice(0, 12)}`;

  const forwardproxy = await github.prefetchArchive(
    `${owner}/${repo}`,
    latest.name,
  );
  const caddyTag = (
    await fs.readFile(`${forwardproxy.storePath}/CADDY_VERSION`, "utf8")
  ).trim();
  const caddy = await github.prefetchArchive("caddyserver/caddy", caddyTag);
  // nixpkgs' caddy installs its systemd units from the dist repository's tag of the same release.
  const dist = await github.prefetchArchive("caddyserver/dist", caddyTag);

  return {
    "source.nix": `${nix.HEADER}{ fetchzip }:

{
  version = ${nix.string(latest.name.slice(1))};
  goVersion = ${nix.string(goVersion)};
  caddyVersion = ${nix.string(caddyTag.slice(1))};
  src = ${fetchzip(forwardproxy)};
  caddySrc = ${fetchzip(caddy)};
  caddyDist = ${fetchzip(dist)};
}
`,
  };
};
