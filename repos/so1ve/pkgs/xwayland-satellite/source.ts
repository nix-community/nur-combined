import { cargo, defineSource, github } from "nix-repin";

export default defineSource(
  github.branch({
    branch: "main",
    repository: "Supreeeme/xwayland-satellite",
  }),
  cargo.lock("Cargo.lock"),
);
