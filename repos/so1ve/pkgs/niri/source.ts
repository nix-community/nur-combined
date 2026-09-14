import { cargo, defineSource, github } from "nix-repin";

export default defineSource(
  github.branch({
    branch: "feat/latchshot-support",
    repository: "so1ve/niri",
  }),
  cargo.lock("Cargo.lock"),
);
