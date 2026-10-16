import { defineSource, nix, runCommand } from "nix-repin";

const url =
  "https://gist.github.com/padeoe/697678ab8e528b85a2a7bddafea1fa4f.git";

// github.branch tracks repositories, so prefetch the gist's default branch directly.
export default defineSource(async () => {
  const { rev, date, hash } = JSON.parse(
    await runCommand("nix-prefetch-git", ["--quiet", "--url", url]),
  );

  return {
    "source.nix": nix.renderSource(
      ["fetchgit"],
      { date: date.slice(0, 10), rev },
      `  src = fetchgit {
    url = ${nix.string(url)};
    inherit rev;
    hash = ${nix.string(hash)};
  };`,
    ),
  };
});
