import { Buffer } from "node:buffer";
import { spawnSync } from "node:child_process";
import { readFile, writeFile } from "node:fs/promises";
import process from "node:process";

interface Config {
  name: string;
  output: string;
  repository: string;
  systems: Record<string, { asset: string }>;
  tagPrefix: string;
}

interface ReleaseAsset {
  browser_download_url: string;
  digest?: string;
  name: string;
}

interface Release {
  assets: ReleaseAsset[];
  tag_name: string;
}

function prefetchHash(nixBin: string, url: string): string {
  const result = spawnSync(nixBin, ["store", "prefetch-file", "--json", url], {
    encoding: "utf8",
  });
  if (result.error) {
    throw result.error;
  }
  if (result.status !== 0) {
    throw new Error(`nix store prefetch-file failed: ${result.stderr.trim()}`);
  }
  return (JSON.parse(result.stdout) as { hash: string }).hash;
}

function assetHash(asset: ReleaseAsset, nixBin: string): string {
  if (asset.digest?.startsWith("sha256:")) {
    const hex = asset.digest.slice("sha256:".length);
    return `sha256-${Buffer.from(hex, "hex").toString("base64")}`;
  }
  console.log(
    `Prefetching ${asset.name} because GitHub did not provide its digest`,
  );
  return prefetchHash(nixBin, asset.browser_download_url);
}

async function fetchRelease(config: Config): Promise<Release> {
  const headers: Record<string, string> = {
    Accept: "application/vnd.github+json",
    "User-Agent": "so1ve-nur-github-release-updater",
    "X-GitHub-Api-Version": "2022-11-28",
  };
  const token = process.env.GITHUB_TOKEN || process.env.GH_TOKEN;
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const response = await fetch(
    `https://api.github.com/repos/${config.repository}/releases/latest`,
    { headers },
  );
  if (!response.ok) {
    throw new Error(
      `GitHub API request failed: ${response.status} ${await response.text()}`,
    );
  }
  return await response.json() as Release;
}

async function update(configPath: string, nixBin: string): Promise<void> {
  const config = JSON.parse(await readFile(configPath, "utf8")) as Config;
  const release = await fetchRelease(config);
  const version = release.tag_name.startsWith(config.tagPrefix)
    ? release.tag_name.slice(config.tagPrefix.length)
    : release.tag_name;

  const sources: Record<string, { asset: string; hash: string }> = {};
  for (const [system, { asset: template }] of Object.entries(config.systems)) {
    const assetName = template
      .replaceAll("{version}", version)
      .replaceAll("{tag}", release.tag_name)
      .replaceAll("{system}", system);
    const asset = release.assets.find(({ name }) => name === assetName);
    if (!asset) {
      throw new Error(
        `release ${release.tag_name} has no asset named ${assetName}`,
      );
    }
    sources[system] = {
      asset: assetName,
      hash: assetHash(asset, nixBin),
    };
  }

  const contents = `${JSON.stringify({ version, sources }, null, 2)}\n`;
  const changed = await readFile(config.output, "utf8") !== contents;
  if (changed) {
    await writeFile(config.output, contents);
  }
  console.log(
    changed
      ? `Updated ${config.name} to ${release.tag_name}`
      : `${config.name} is already at ${release.tag_name}`,
  );
}

if (import.meta.main) {
  const [configPath, nixBin] = process.argv.slice(2) as [string, string];
  try {
    await update(configPath, nixBin);
  } catch (error) {
    console.error(
      `error: ${error instanceof Error ? error.message : String(error)}`,
    );
    process.exitCode = 1;
  }
}
