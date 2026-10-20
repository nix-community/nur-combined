{ lib, pkgs, applyPatches, codex-computer-use-niri }:
let
  base = import ./base.nix { inherit pkgs; };
  backend = codex-computer-use-niri;
  patchedSource = applyPatches {
    name = "codex-desktop-linux-native-launch-source";
    src = backend.backendSource;
    patches = [ ./codex-linux-native-launch.patch ];
  };
  pluginDir = "opt/codex-desktop/resources/plugins/openai-bundled/plugins/unified-computer-use";
in
(base.override { linuxFeatureIds = [ "computer-use-linux" ]; }).overrideAttrs (old: {
  postInstall = (old.postInstall or "") + ''
    install -m755 ${backend}/bin/codex-computer-use-linux \
      "$out/${pluginDir}/bin/codex-computer-use-linux"
    for script in native-client native-service native-backend-service native-protocol; do
      install -m644 ${patchedSource}/linux-features/computer-use-linux/$script.mjs \
        "$out/${pluginDir}/scripts/$script.mjs"
    done
    substituteInPlace "$out/${pluginDir}/scripts/native-client.mjs" \
      --replace-fail 'const browserState = cua.getState?.bind(cua);' \
      'const listBrowsers = cua.listBrowsers?.bind(cua);
    const listTabs = cua.listTabs?.bind(cua);
    const browserState = async () => ({ browsers: !listBrowsers ? [] : await Promise.all(
      (await listBrowsers({ emit: false })).map(async browser => ({
        ...browser, tabs: await listTabs({ browser: browser.id, emit: false }),
      })),
    ) });'
  '';
  passthru = (old.passthru or { }) // { niriBackend = backend; };
  meta = old.meta // {
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
})
