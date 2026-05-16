{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "oc-tps";
  version = "0.0.6-unstable-2026-04-05";

  src = fetchFromGitHub {
    owner = "Tarquinen";
    repo = pname;
    rev = "db92be7f44a32ee577d758e43e71054741eb936a";
    hash = "sha256-P6saPaegM7Rxsaiia54TnZ41ovAdjJEQkRZkgM2aVLE=";
  };

  dependencyHash = "sha256-gY2W8YA1yl6ZkodXRHHf9LEmedWyuek4Y+HUyDln7i8=";
  dependencyInstallCommand = "BUN_CONFIG_SKIP_SAVE_LOCKFILE=1 bun install --no-cache --ignore-scripts";

  buildCommand = ''
    bun -e '
      import solid from "@opentui/solid/bun-plugin"

      const result = await Bun.build({
        entrypoints: ["tui.tsx"],
        outdir: "dist",
        target: "node",
        format: "esm",
        plugins: [solid],
        external: ["@opencode-ai/plugin/tui", "@opentui/solid", "solid-js"],
      })

      if (!result.success) {
        console.error(result.logs.join("\n"))
        process.exit(1)
      }
    '
  '';

  postInstall = ''
    bun -e '
      const packageJson = await Bun.file("package.json").json()
      packageJson.main = "./dist/tui.js"
      packageJson.exports = {
        ".": {
          import: "./dist/tui.js",
        },
        "./tui": {
          import: "./dist/tui.js",
        },
      }
      await Bun.write("package.json", `''${JSON.stringify(packageJson, null, 2)}\n`)
    '
  '';

  meta = {
    # keep-sorted start
    description = "OpenCode TUI plugin that displays live TPS, average TPS, and TTFT in the session prompt";
    homepage = "https://github.com/Tarquinen/oc-tps";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
