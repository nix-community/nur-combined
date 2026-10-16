import { github } from "nix-repin";

export default github.release({
  assets: {
    "x86_64-linux": "AlgerMusicPlayer-{version}-linux-x86_64.AppImage",
  },
  repository: "algerkong/AlgerMusicPlayer",
  stripPrefix: "v",
});
