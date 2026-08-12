import { github } from "nix-repin";

export default github.branch({
  branch: "feat/window-geometries",
  cargoLock: "Cargo.lock",
  repository: "so1ve/niri",
});
