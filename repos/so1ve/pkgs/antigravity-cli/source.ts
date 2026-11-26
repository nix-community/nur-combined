import { defineSource, fetchurl } from "nix-repin";

const baseUrl =
  "https://storage.googleapis.com/antigravity-public/antigravity-cli";

export default defineSource(async (source) => {
  const version = (await (await fetch(`${baseUrl}/latest`)).text()).trim();
  if (await source.shouldSkip(() => source.matches({ version }))) {
    return false;
  }

  const { platforms } = (await (
    await fetch(`${baseUrl}/${version}/manifest.json`)
  ).json()) as { platforms: Record<string, { url: string }> };

  return fetchurl({
    version,
    urls: {
      "x86_64-linux": platforms["linux-x64"].url,
      "aarch64-linux": platforms["linux-arm"].url,
    },
  });
});
