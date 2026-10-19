import { defineSource, fetchurl, npm } from "nix-repin";

export default defineSource(async (context) => {
  const files = await npm.pkg({ name: "rea-agents" })(context);
  const lock = JSON.parse(
    files["package-lock.json"] as string ??
      await Deno.readTextFile(`${context.packageDirectory}/package-lock.json`),
  );

  const fridaVersion = lock.packages["node_modules/frida"].version;
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

  return { ...files, "frida.nix": frida["source.nix"] };
});
