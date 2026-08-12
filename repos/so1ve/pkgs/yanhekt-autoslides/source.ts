import { github } from "nix-repin";

export default github.release({
  repository: "BIT-Admin/Yanhekt-AutoSlides",
  stripPrefix: "v",
});
