import { defineSource, github } from "nix-repin";

export default defineSource(
  github.tag({
    repository: "q1uuuu/agy-context",
    tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+",
    stripPrefix: "v",
  }),
  async () => {
    const commit = "1463aa8b54de11078af2718b78c25d3776d0df13";
    const { hash } = await github.prefetchArchive("lbyxiaolizi/agy-context", commit);
    return { "pins.json": `${JSON.stringify({ commit, hash }, null, 2)}\n` };
  },
);
