import { defineSource, github, Source } from "nix-repin";

const waywallen = github.release({
  assets: {
    "aarch64-linux": "waywallen-{version}-aarch64\\.AppImage",
    "x86_64-linux": "waywallen-{version}-x86_64\\.AppImage",
  },
  repository: "waywallen/waywallen",
  stripPrefix: "v",
});

const plugins = {
  "open-wallpaper-engine": {
    id: "org.waywallen.open-wallpaper-engine",
    license: "gpl2Only",
    release: {
      assets: {
        "aarch64-linux":
          "open-wallpaper-engine-{version}-linux-aarch64\\.zip",
        "x86_64-linux":
          "open-wallpaper-engine-{version}-linux-x86_64\\.zip",
      },
      repository: "waywallen/open-wallpaper-engine",
      stripPrefix: "v",
    },
  },
};

export default defineSource(waywallen, async (source) => {
  const entries = Object.entries(plugins);
  const sources = await Promise.all(
    entries.map(async ([name, { release }]) => {
      const plugin = new Source(source.packageDirectory);
      await plugin.apply(github.release(release));

      return [`plugins/${name}.nix`, plugin.files()["source.nix"]] as const;
    }),
  );
  const catalog = Object.fromEntries(
    entries.map(([name, { id, license }]) => [name, { id, license }]),
  );

  return {
    ...Object.fromEntries(sources),
    "plugins/catalog.json": JSON.stringify(catalog, null, 2) + "\n",
  };
});
