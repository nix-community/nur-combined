# jadx-headless-mcp packaging guide

`default.nix` builds this Gradle/Kotlin project from source, and the Gradle
dependency tree is pinned by `deps.json` (a nixpkgs Gradle lockfile consumed
through `gradle_9.fetchDeps` / `mitmCache`).

## Source of truth

- `default.nix` — the derivation: Gradle 9.8.0 (`gradle_9`), JDK 17 toolchain,
  `installDist` + `shadowJar`, wrapped launcher, `passthru.jar`.
- `jar.nix` — `passthru.jar`: the fat jar as a package of its own.
- `deps.json` — Gradle dependency lockfile; regenerate on every version bump.

## Why these choices

- **`gradle_9`, not `gradle`**: upstream's wrapper pins `gradle-9.8.0`; nixpkgs
  `gradle` is 8.x and cannot configure the Kotlin 2.4.20 / shadow 9.6.1 plugins.
- **`-Dorg.gradle.java.installations.paths=${jdk17_headless.home}`**: `build.gradle.kts`
  declares `kotlin { jvmToolchain(17) }` and the Gradle setup hook builds with
  `--offline`, so the toolchain has to resolve to the Nix JDK
  (`/nix/store/...-openjdk-headless-17.../lib/openjdk`).
- **Headless JDK, not the full one**: `jdk17_headless` (openjdk-headless, 520 MiB
  closure) still ships every module including `java.desktop`/`java.xml` plus
  `javac`/`jar`, but drops the X11/GTK stack — the full `jdk17` would add ~260 MiB
  (782 MiB closure) for a server that never opens a window.
- **`installDist` plus `shadowJar`**: the `application` plugin's launcher carries
  upstream's `applicationDefaultJvmArgs` (heap limits, slf4j to stderr), and the
  fat jar built in the same Gradle pass is what `passthru.jar` re-exports
  (mirroring `pctx.passthru.py`). Upstream's own Claude Code plugin instead
  downloads that jar at first start — never use that path here.
- **`passthru.jar`** (`jar.nix`): a `stdenvNoCC` derivation whose output is a
  symlink to the jar inside this package's output, so

  ```bash
  java -jar "$(nix build .#jadx-headless-mcp.jar --print-out-paths)"
  ```

  gives an absolute path with no build cost and no duplicate bytes in the store.
- **The wrapper sets `JAVA_HOME`** to the same JDK 17 rather than relying on
  `java` being on `PATH`.

## Updating to a new upstream tag

1. Bump `version` (and the `src` hash) to the new `v*` tag; confirm the tag
   matches `version = "..."` in upstream `build.gradle.kts`.
2. Regenerate the dependency lockfile:

   ```bash
   nix-build --no-out-link -A jadx-headless-mcp.mitmCache.updateScript
   # then run the script path printed above; it writes pkgs/jadx-headless-mcp/deps.json
   ```

   The script runs upstream's build inside a `bwrap` sandbox behind a recording
   HTTP proxy and rewrites `deps.json`. If the sandbox refuses to start, retry
   with `USE_BWRAP=0`.

3. Rebuild: `nix-build -A jadx-headless-mcp`.
4. Smoke test (stdio MCP, so `--help` alone is not enough):

   ```bash
   result/bin/jadx-headless-mcp --help
   printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"1"}}}' \
     | timeout 60 result/bin/jadx-headless-mcp
   ```

   The `initialize` reply must come back as JSON on stdout (stdout is the
   JSON-RPC channel; logs go to stderr).

## Failure modes seen before

- Missing artifacts during the offline build → the configuration that pulls them
  was not resolved when `deps.json` was generated; extend the collection run
  (e.g. `gradleUpdateTask = "nixDownloadDeps installDist"`) and regenerate.
- Gradle trying to download a JDK 17 toolchain → `org.gradle.java.installations.paths`
  / `auto-download=false` were dropped.
