import { defineSource, github, npm } from "nix-repin";

export default defineSource(
  github.release({
    repository: "BIT-Admin/Yanhekt-AutoSlides",
    stripPrefix: "v",
  }),
  npm.lock({ path: "autoslides/package-lock.json" }),
);
