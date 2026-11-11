import { defineSource, github } from "nix-repin";

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
          "org\\.waywallen\\.open-wallpaper-engine-{version}-linux-aarch64\\.zip",
        "x86_64-linux":
          "org\\.waywallen\\.open-wallpaper-engine-{version}-linux-x86_64\\.zip",
      },
      repository: "waywallen/open-wallpaper-engine",
      stripPrefix: "v",
    },
  },
};

export default defineSource(async (context) => {
  const entries = Object.entries(plugins);
  const [app, ...sources] = await Promise.all([
    waywallen(context),
    ...entries.map(async ([name, { release }]) => {
      const files = await github.release(release)(context);
      return [`plugins/${name}.nix`, files["source.nix"]] as const;
    }),
  ]);
  const catalog = Object.fromEntries(
    entries.map(([name, { id, license }]) => [name, { id, license }]),
  );

  return {
    ...app,
    ...Object.fromEntries(sources),
    "plugins/catalog.json": JSON.stringify(catalog, null, 2) + "\n",
  };
});
