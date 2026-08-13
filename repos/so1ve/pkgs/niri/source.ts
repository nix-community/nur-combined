import { github } from "nix-repin";

export default github.branch({
  branch: "feat/latchshot-support",
  cargoLock: "Cargo.lock",
  repository: "so1ve/niri",
});
