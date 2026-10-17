import { codeberg, defineSource, github, nix, provider } from "nix-repin";

export default defineSource(
  github.tag({
    repository: "Zencok/BakaMusic",
    tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+",
    stripPrefix: "v",
  }),
  // The release's media runtime manifest and npm lock name the LibreMPEG and koffi commits it builds against.
  provider(async (source) => {
    const { mpv } = JSON.parse(
      await Deno.readTextFile(
        source.sourceFile("scripts/media-runtime-manifest.json"),
      ),
    );
    if (
      mpv.engine !== "libmpv" || mpv.mediaBackend !== "librempeg" ||
      !mpv.decoders.includes("ac4")
    ) {
      throw new Error(
        `bakamusic: the media runtime is now ${mpv.engine}/${mpv.mediaBackend} decoding ${mpv.decoders}; review the packaging`,
      );
    }

    const lock = JSON.parse(
      await Deno.readTextFile(source.sourceFile("package-lock.json")),
    );
    const koffiVersion: string = lock.packages["node_modules/koffi"].version;
    // rygel tags each koffi release koffi/<version>.
    const koffiTag = `koffi/${koffiVersion}`;
    const [{ rev: koffiCommit }, { version: taggedVersion }] = await Promise
      .all([
        codeberg.resolveRef("Koromix/rygel", koffiTag),
        codeberg.readFile("Koromix/rygel", koffiTag, "src/koffi/package.json")
          .then(JSON.parse),
      ]);
    if (taggedVersion !== koffiVersion) {
      throw new Error(
        `bakamusic: rygel tag ${koffiTag} carries koffi ${taggedVersion}`,
      );
    }

    const [koffi, librempeg] = await Promise.all([
      codeberg.prefetchArchive("Koromix/rygel", koffiCommit, { unpack: false }),
      nix.prefetch(
        `https://github.com/librempeg/librempeg/archive/${mpv.sourceCommits.librempeg}.tar.gz`,
      ),
    ]);
    const pins = {
      koffi: { commit: koffiCommit, hash: koffi.hash, version: koffiVersion },
      mpvRuntime: {
        decoders: mpv.decoders,
        engine: mpv.engine,
        librempeg: {
          commit: mpv.sourceCommits.librempeg,
          hash: librempeg.hash,
        },
        mediaBackend: mpv.mediaBackend,
        version: mpv.version,
      },
    };

    return { "pins.json": `${JSON.stringify(pins, null, 2)}\n` };
  }),
);
