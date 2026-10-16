import { defineSource, github, nix, provider } from "nix-repin";

async function codeberg(path: string) {
  const response = await fetch(`https://codeberg.org/${path}`);
  if (!response.ok) {
    throw new Error(
      `bakamusic: codeberg.org/${path} returned ${response.status}`,
    );
  }

  return await response.json();
}

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
    const koffiRef = encodeURIComponent(`koffi/${koffiVersion}`);
    const [{ sha: koffiCommit }, { version: taggedVersion }] = await Promise
      .all([
        codeberg(`api/v1/repos/Koromix/rygel/git/commits/${koffiRef}`),
        codeberg(`Koromix/rygel/raw/tag/${koffiRef}/src/koffi/package.json`),
      ]);
    if (taggedVersion !== koffiVersion) {
      throw new Error(
        `bakamusic: rygel tag koffi/${koffiVersion} carries koffi ${taggedVersion}`,
      );
    }

    const [koffi, librempeg] = await Promise.all([
      nix.prefetch(
        `https://codeberg.org/Koromix/rygel/archive/${koffiCommit}.tar.gz`,
      ),
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
