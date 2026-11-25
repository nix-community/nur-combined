import { github } from "nix-repin";

export const formatJson = (value: unknown): string =>
  `${JSON.stringify(value, null, 2)}\n`;

export const cooldownCutoff = (hours = 24): string =>
  new Date(Date.now() - hours * 60 * 60 * 1000).toISOString();

export const parseGitHubSource = (source: string): string | null =>
  source.startsWith("github:") ? source.slice("github:".length) : null;

export interface GitHubCommitArchive {
  rev: string;
  date: string;
  url: string;
  hash: string;
  storePath: string;
}

export async function fetchGitHubCommitArchive(options: {
  repository: string;
  branch?: string;
  before?: string;
}): Promise<GitHubCommitArchive> {
  const { rev, date } = await github.latestCommit(options);
  const { url, hash, storePath } = await github.prefetchArchive(
    options.repository,
    rev,
  );
  return { rev, date, url, hash, storePath };
}
