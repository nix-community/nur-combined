import { defineSource, github, npm } from "nix-repin";

export default defineSource(
  github.release({
    repository: "BIT-Admin/Yanhekt-AutoSlides",
    stripPrefix: "v",
  }),
  npm.lock("autoslides/package-lock.json"),
);
