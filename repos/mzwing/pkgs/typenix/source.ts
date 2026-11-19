import { defineSource, github, nix, npm } from "nix-repin";
import { gomod2nix } from "../../internal/sources.ts";

export default defineSource(
  github.branch({
    repository: "ryanrasti/typenix",
    branch: "main",
  }),
  gomod2nix(),
  // typenix-vscode builds the editor extension from this tree.
  npm.lock({ path: "_extension/package-lock.json" }),
  // Build against the tree-sitter-nix revision typenix's own flake locks.
  async (source) => {
    const lock = JSON.parse(await source.readSourceFile("flake.lock"));
    const { owner, repo, rev, narHash } = lock.nodes["tree-sitter-nix"].locked;

    return {
      "tree-sitter-nix.nix": nix.renderArchive(
        { url: github.archiveUrl(`${owner}/${repo}`, rev), hash: narHash },
        { rev },
      ),
    };
  },
);
