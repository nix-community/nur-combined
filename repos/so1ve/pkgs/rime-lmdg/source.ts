import { github } from "nix-repin";

export default github.release({
  assets: {
    default: "wanxiang-lts-zh-hans\\.gram",
  },
  repository: "jetcookies/RIME-LMDG-tracker",
});
