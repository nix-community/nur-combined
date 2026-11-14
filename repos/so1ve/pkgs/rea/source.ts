import { defineSource, fetchurl, npm } from "nix-repin";

export default defineSource(
  npm.pkg({ name: "rea-agents" }),
  async (source) => {
    const lock = JSON.parse(source.files()["package-lock.json"] as string);

    const fridaVersion =
      lock.packages["node_modules/rea-agents/node_modules/frida"].version;
    const fridaRelease =
      `https://github.com/frida/frida/releases/download/${fridaVersion}`;
    const frida = await fetchurl({
      version: fridaVersion,
      urls: {
        "x86_64-linux":
          `${fridaRelease}/frida-v${fridaVersion}-napi-v8-linux-x64.tar.gz`,
        "aarch64-linux":
          `${fridaRelease}/frida-v${fridaVersion}-napi-v8-linux-arm64.tar.gz`,
      },
    });

    return { "frida.nix": frida["source.nix"] };
  },
);
