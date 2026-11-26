import { defineSource, github, nix } from "nix-repin";

export default defineSource(async (source) => {
  const { rev } = await github.latestCommit({
    repository: "klzgrad/forwardproxy",
    branch: "naive",
  });
  const response = await fetch(
    `https://proxy.golang.org/github.com/klzgrad/forwardproxy/@v/${rev}.info`,
  );
  if (!response.ok) {
    throw new Error(`Go module version lookup failed: ${response.status}`);
  }
  const { Version: version } = (await response.json()) as { Version: string };
  const plugin = `github.com/caddyserver/forwardproxy=github.com/klzgrad/forwardproxy@${version}`;
  const caddyVersion = await nix.evalNixpkgs<string>(
    source.packageDirectory,
    "caddy.version",
  );

  if (
    await source.shouldSkip(() =>
      source.matches({ caddyVersion, plugins: [plugin] }),
    )
  ) {
    return false;
  }

  const root = await nix.findFlakeRoot(source.packageDirectory);
  const hash = await nix.fixedOutputHash(`let
  flake = builtins.getFlake ${nix.string(`path:${root}`)};
  pkgs = flake.inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
in (pkgs.caddy.withPlugins {
  plugins = [ ${nix.string(plugin)} ];
  hash = pkgs.lib.fakeHash;
}).src`);

  return {
    "source.nix": `${nix.HEADER}{ }:

{
  caddyVersion = ${nix.string(caddyVersion)};
  plugins = [ ${nix.string(plugin)} ];
  hash = ${nix.string(hash)};
}
`,
  };
});
