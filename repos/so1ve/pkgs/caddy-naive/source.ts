import { defineSource, github, nix, runCommand } from "nix-repin";

export default defineSource(async (context) => {
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
  const { Version: version } = await response.json();
  const plugin =
    `github.com/caddyserver/forwardproxy=github.com/klzgrad/forwardproxy@${version}`;
  const root = await nix.findFlakeRoot(context.packageDirectory);
  const expression = `let
  flake = builtins.getFlake ${nix.string(`path:${root}`)};
  pkgs = flake.inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
in (pkgs.caddy.withPlugins {
  plugins = [ ${nix.string(plugin)} ];
  hash = pkgs.lib.fakeHash;
}).src`;

  // withPlugins vendors Caddy and the plugin together. Ask Nix for that hash.
  let hash: string;
  try {
    await runCommand("nix", [
      "build",
      "--impure",
      "--no-link",
      "--expr",
      expression,
    ]);
    throw new Error(
      "Expected a source hash mismatch from the placeholder hash",
    );
  } catch (error) {
    const match = String(error).match(
      /hash mismatch in fixed-output derivation[\s\S]*?got:\s+(sha256-[A-Za-z0-9+/]+=*)/,
    );
    if (!match) throw error;
    hash = match[1];
  }

  const patchUrl =
    `https://raw.githubusercontent.com/klzgrad/forwardproxy/${rev}/caddy-read-idle-timeout.patch`;
  const patch = await nix.prefetch(patchUrl);

  return {
    "source.nix": `${nix.HEADER}{ fetchurl }:

{
  plugins = [ ${nix.string(plugin)} ];
  hash = ${nix.string(hash)};
  patch = fetchurl {
    url = ${nix.string(patchUrl)};
    hash = ${nix.string(patch.hash)};
  };
}
`,
  };
});
