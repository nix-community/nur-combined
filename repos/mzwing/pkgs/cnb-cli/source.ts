import { defineSource, fetchurl } from "nix-repin";

// The npm tarball is the release, so follow the registry's latest dist-tag.
export default defineSource(async () => {
  const response = await fetch(
    "https://registry.npmjs.org/@cnbcool/cnb-cli/latest",
  );
  if (!response.ok) {
    throw new Error(`cnb-cli: the npm registry returned ${response.status}`);
  }
  const { version, dist } = await response.json();

  return fetchurl({ version, urls: { default: dist.tarball } });
});
