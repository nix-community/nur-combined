{
  lib,
  buildNpmPackage,
  callPackage,
  fetchzip,
  nodejs_24,
  stdenvNoCC,
  deepseek-harness ? callPackage ../deepseek-harness { },
}:

let
  catalog = import ./catalog.nix { inherit lib; };
  manifest = builtins.fromJSON (builtins.readFile ./manifest.json);
in
lib.recurseIntoAttrs (
  lib.mapAttrs (
    name: plugin:
    let
      source = manifest.${name};
      fromGit = lib.hasPrefix "github:" name;
      builder = if fromGit then stdenvNoCC.mkDerivation else buildNpmPackage;
    in
    builder {
      pname = lib.strings.sanitizeDerivationName plugin.packageName;
      inherit (source) version;

      src =
        if fromGit then
          fetchzip {
            inherit (source) url hash;
            extension = "tar.gz";
          }
        else
          ./locks + "/${plugin.packageName}";

      nodejs = nodejs_24;
      npmDepsHash = source.npmDepsHash or null;
      npmFlags = [
        "--ignore-scripts"
        "--legacy-peer-deps"
      ];

      dontBuild = true;
      nativeBuildInputs = lib.optional fromGit nodejs_24;

      postPatch = lib.optionalString (name == "github:YuJunZhiXue/dsh-purge") ''
        node --expose-internals ${./adapt-purge.mjs}
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

        ${lib.optionalString (name == "github:YuJunZhiXue/dsh-purge") ''
          const { default: assert } = await import('node:assert/strict');
          const root = process.env.out + '/lib/node_modules/dsh-purge/lib/';
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
    }
  ) (lib.filterAttrs (_: plugin: !plugin.bundled) catalog)
)
