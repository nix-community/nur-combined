import { cargo, defineSource, github } from "nix-repin";

export default defineSource(
  github.branch({
    branch: "fix/overlay-hot-corners",
    repository: "so1ve/niri",
  }),
  cargo.lock(),
);
