#!/usr/bin/env bun
// Update versions.json with the latest Paper build per Minecraft version.
//
// The fill API reports the artifact sha256 directly, so (unlike the other
// game-server updaters) no jar downloads are needed.
//
// Usage:
//   bun ./update.ts            # fetch versions, update versions.json
//   ./update.ts                # same, via bun shebang (bun is in the dev shell)

import {
  fetchJson,
  isMcVersionSupported,
  loadVersions,
  sriFromHex,
  writeVersions,
} from "../../scripts/update-lib.ts";

const GRAPHQL_URL = "https://fill.papermc.io/graphql";
const VERSIONS_PATH = `${import.meta.dir}/versions.json`;

interface VersionsResponse {
  project: {
    versions: {
      nodes: Array<{
        key: string;
        family: { key: string };
      }>;
    };
  };
}

interface BuildsResponse {
  project: {
    version: {
      builds: {
        nodes: Array<{
          number: number;
          downloads: Array<{
            name: string;
            url: string;
            checksums: { sha256: string };
          }>;
        }>;
      };
    };
  };
}

interface CachedEntry {
  hash: string;
  version: string;
  url: string;
}

async function graphql<T>(query: string, variables?: Record<string, string>) {
  const result = await fetchJson<{ data: T; errors?: unknown }>(GRAPHQL_URL, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(variables ? { query, variables } : { query }),
  });
  if (result.errors) {
    throw new Error(`GraphQL errors: ${JSON.stringify(result.errors)}`);
  }
  return result.data;
}

async function main(): Promise<void> {
  const existing = await loadVersions<CachedEntry>(VERSIONS_PATH);

  console.log("Fetching Paper versions ...");
  const versionData = await graphql<VersionsResponse>(`
    query {
      project(key: "paper") {
        versions(first: 100) {
          nodes {
            key
            family {
              key
            }
          }
        }
      }
    }
  `);
  const mcVersions = versionData.project.versions.nodes
    .map((n) => n.key)
    .filter((v) => !v.includes("pre") && !v.includes("rc"))
    .filter((v) => isMcVersionSupported(v));

  const out: Record<string, CachedEntry> = {};
  for (const mc of mcVersions) {
    const buildData = await graphql<BuildsResponse>(
      `
        query ($version: String!) {
          project(key: "paper") {
            version(key: $version) {
              builds(last: 1) {
                nodes {
                  number
                  downloads {
                    name
                    url
                    checksums {
                      sha256
                    }
                  }
                }
              }
            }
          }
        }
      `,
      { version: mc },
    );
    const builds = buildData.project.version.builds.nodes;
    if (builds.length === 0) {
      console.log(`No builds found for version ${mc}`);
      continue;
    }
    const build = builds[0];
    const fullName = `${mc}-${build.number}`;
    const download = build.downloads.find((d) => d.name.endsWith(".jar"));
    if (!download) {
      console.log(`No jar download found for version ${fullName}`);
      continue;
    }
    const cached = existing[mc];
    if (cached && cached.version === fullName && cached.hash) {
      console.log(`Version ${fullName} already cached`);
      out[mc] = { ...cached, url: cached.url ?? download.url };
      continue;
    }
    const hash = sriFromHex(download.checksums.sha256);
    console.log(`Version ${fullName} fetched`);
    out[mc] = { hash, version: fullName, url: download.url };
  }

  await writeVersions(VERSIONS_PATH, out);
}

await main();
