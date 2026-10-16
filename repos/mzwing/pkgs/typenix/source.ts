import { defineSource, github, nix, npm, provider } from "nix-repin";
import { gomod2nix } from "../../internal/sources.ts";

export default defineSource(
  github.branch({
    repository: "ryanrasti/typenix",
    branch: "main",
  }),
  gomod2nix(),
  // typenix-vscode builds the editor extension from this tree.
  npm.lock("_extension/package-lock.json"),
  // Build against the tree-sitter-nix revision typenix's own flake locks.
  provider(async (source) => {
    const lock = JSON.parse(
      await Deno.readTextFile(source.sourceFile("flake.lock")),
    );
    const { owner, repo, rev, narHash } = lock.nodes["tree-sitter-nix"].locked;

    return {
      "tree-sitter-nix.nix": nix.renderSource(
        ["fetchzip"],
        { rev },
        `  src = fetchzip {
    url = ${
          nix.string(
            `https://codeload.github.com/${owner}/${repo}/tar.gz/${rev}`,
          )
        };
    hash = ${nix.string(narHash)};
    extension = "tar.gz";
  };`,
      ),
    };
  }),
);
