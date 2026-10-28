import { compare, parse } from "@std/semver";
import { github, nix, provider } from "nix-repin";
import { Octokit } from "octokit";

const owner = "klzgrad";
const repo = "forwardproxy";

const octokit = new Octokit({
  auth: Deno.env.get("GITHUB_TOKEN") ?? Deno.env.get("GH_TOKEN"),
});

const fetchzip = (archive: github.ArchiveSource) =>
  `fetchzip {
    url = ${nix.string(archive.url)};
    hash = ${nix.string(archive.hash)};
    extension = "tar.gz";
  }`;

// The fork's go.mod keeps the module path without /v2, so Go refuses its v2 tags as versions; xcaddy gets the naive tag's commit as a pseudo-version instead.
// Each tag also carries the Caddy patches its release builds apply, and names that Caddy release in CADDY_VERSION.
export default provider(async () => {
  const tags = await octokit.paginate(octokit.rest.repos.listTags, {
    owner,
    repo,
    per_page: 100,
  });
  const [latest] = tags
    .filter((tag) => /^v\d+\.\d+\.\d+-naive\d*$/.test(tag.name))
    .sort((a, b) => compare(parse(b.name.slice(1)), parse(a.name.slice(1))));
  if (!latest) {
    throw new Error(`${owner}/${repo}: no naive tag found`);
  }

  const { data: commit } = await octokit.rest.repos.getCommit({
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
  const caddyTag = (await Deno.readTextFile(
    `${forwardproxy.storePath}/CADDY_VERSION`,
  )).trim();
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
});
