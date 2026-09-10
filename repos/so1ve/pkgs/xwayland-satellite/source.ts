import { github } from "nix-repin";

export default github.branch({
  branch: "main",
  cargoLock: "Cargo.lock",
  repository: "Supreeeme/xwayland-satellite",
});
