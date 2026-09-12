import { aur } from "nix-repin";

export default aur.pkg({
  name: "baidunetdisk-bin",
  urls: {
    default:
      "https://pkg-ant.baidu.com/issue/netdisk/LinuxGuanjia/{version}/baidunetdisk_{version}_amd64.deb",
  },
});
