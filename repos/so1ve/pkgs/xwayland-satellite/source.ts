import { github } from "nix-repin";

export default github.branch({
  branch: "fix/issue-301",
  cargoLock: "Cargo.lock",
  repository: "so1ve/xwayland-satellite",
});
