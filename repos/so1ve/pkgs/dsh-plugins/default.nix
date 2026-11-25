{
  lib,
  buildNpmPackage,
  callPackage,
  deepseek-harness,
  nodejs_24,
}:

let
  pluginLib = callPackage ../../lib/plugins.nix { };
  catalog = import ./catalog.nix { inherit lib; };
in
pluginLib.mkPluginSet {
  inherit catalog;
  manifestPath = ./manifest.json;
  filter = _: plugin: !plugin.bundled;

  buildPlugin =
    {
      name,
      plugin,
      source,
    }:
    let
      fromGit = lib.hasPrefix "github:" name;
    in
    buildNpmPackage {
      pname = lib.strings.sanitizeDerivationName plugin.packageName;
      inherit (source) version;

      src = if fromGit then pluginLib.fetchGitHubArchive source else ./locks + "/${plugin.packageName}";

      nodejs = nodejs_24;
      inherit (source) npmDepsHash;
      npmFlags = [
        "--ignore-scripts"
        "--legacy-peer-deps"
        "--omit=dev"
      ];

      dontNpmBuild = true;

      postPatch = lib.optionalString (name == "github:kingcharleslzy-ai/dsh-purge") ''
        ${lib.getExe nodejs_24} --expose-internals ${./adapt-purge.mjs}
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/lib/node_modules"
        ${
          if fromGit then
            ''cp -r . "$out/lib/node_modules/${plugin.packageName}"''
          else
            ''cp -r node_modules/. "$out/lib/node_modules/"''
        }

        ${lib.optionalString (name == "npm:@anionex/dsh-turn-rewind") ''
          # Allow newer prerelease RCs within the same minor release line without
          # bypassing compatibility checks across minor or major upgrades.
          ${lib.getExe nodejs_24} -e '
            const fs = require("node:fs");
            const file = process.argv[1];
            const pkg = JSON.parse(fs.readFileSync(file, "utf8"));
            const range = pkg.peerDependencies?.["@deepseek-ai/dsh-settings"];
            if (typeof range === "string") {
              pkg.peerDependencies["@deepseek-ai/dsh-settings"] = range
                .split("||")
                .map((part) => {
                  const trimmed = part.trim();
                  const match = /^(\d+\.\d+\.\d+)-rc\.\d+$/.exec(trimmed);
                  return match ? ">=" + trimmed + " <=" + match[1] : trimmed;
                })
                .join(" || ");
              fs.writeFileSync(file, JSON.stringify(pkg, null, 2) + "\n");
            }
          ' "$out/lib/node_modules/${plugin.packageName}/package.json"
        ''}

        # Resolve peers from dsh so plugins share the same module instances.
        ln -s ${deepseek-harness}/share/deepseek-harness/node_modules "$out/node_modules"

        runHook postInstall
      '';

      doInstallCheck = true;
      installCheckPhase = ''
        runHook preInstallCheck

        node --expose-internals --input-type=module <<'JS'
        import { createRequire } from 'node:module';
        import { pathToFileURL } from 'node:url';

        const require = createRequire(process.env.out + '/lib/package.json');
        await import(pathToFileURL(require.resolve(${builtins.toJSON plugin.packageName})));

        ${lib.optionalString (name == "github:kingcharleslzy-ai/dsh-purge") ''
          const { default: assert } = await import('node:assert/strict');
          const root = process.env.out + '/lib/node_modules/dsh-purge-community/lib/';
          const core = await import(pathToFileURL(root + 'core.js'));

          assert.deepEqual(core.patchWatchedClientBundlesSync('/not-writable'), []);
          for (const action of ['applyPatches', 'revertAll', 'patchAllShims', 'revertAllShims']) {
            await assert.rejects(() => core[action]('/not-writable'), /managed by Nix/);
          }

          const updater = await import(pathToFileURL(root + 'update.js'));
          await assert.rejects(() => updater.applyUpdate([]), /managed by Nix/);

          const uninstaller = await import(pathToFileURL(root + 'uninstall.js'));
          await assert.rejects(() => uninstaller.uninstallPurge(), /managed by Nix/);
        ''}
        JS

        runHook postInstallCheck
      '';

      passthru = {
        inherit (plugin) packageName;
      };

      meta = {
        inherit (plugin) description;
        homepage = "https://github.com/${
          if fromGit then lib.removePrefix "github:" name else plugin.repository
        }";
        license = lib.licenses.${plugin.license};
        platforms = deepseek-harness.meta.platforms;
      };
    };
}
