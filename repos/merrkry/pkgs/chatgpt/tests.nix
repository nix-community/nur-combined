{
  lib,
  runCommand,
  closureInfo,
  dpkg,
  patchelf,
  ripgrep,
  chatgpt,
}:

let
  app = chatgpt.unwrapped;
  inherit (app) components;
  closure = closureInfo { rootPaths = [ chatgpt ]; };
  componentClosure = closureInfo {
    rootPaths = [
      components.cua_node
      components.tectonic
    ];
  };
  renamedApp = app.override {
    source = {
      version = "${app.version}-next";
      src = app.src.overrideAttrs (_: {
        name = "chatgpt-next.deb";
      });
      inherit (app) componentHashes;
    };
  };
in
{
  # Check independence from the app's identity, not reuse across real releases.
  componentPathIndependence =
    assert app.outPath != renamedApp.outPath;
    assert components.cua_node.outPath == renamedApp.components.cua_node.outPath;
    assert components.tectonic.outPath == renamedApp.components.tectonic.outPath;
    runCommand "chatgpt-component-path-independence" { } ''
      touch "$out"
    '';

  closure = runCommand "chatgpt-component-closure" { } ''
    grep -Fx ${components.cua_node} ${closure}/store-paths
    grep -Fx ${components.tectonic} ${closure}/store-paths
    grep -Fx ${ripgrep} ${closure}/store-paths

    for path in ${app.src} ${components.cua_node.src} ${dpkg} ${patchelf}; do
      if grep -Fx "$path" ${closure}/store-paths; then
        echo "Unexpected build input in runtime closure: $path" >&2
        exit 1
      fi
    done

    for path in ${chatgpt} ${app}; do
      if grep -Fx "$path" ${componentClosure}/store-paths; then
        echo "Unexpected app dependency in component closure: $path" >&2
        exit 1
      fi
    done

    test "$(readlink ${app}/lib/chatgpt/resources/cua_node)" = ${components.cua_node}
    test "$(readlink ${app}/lib/chatgpt/resources/tectonic)" = ${components.tectonic}
    test "$(readlink ${app}/lib/chatgpt/resources/rg)" = ${lib.getExe ripgrep}
    touch "$out"
  '';

  components = runCommand "chatgpt-components-smoke" { } ''
    ${components.cua_node}/bin/node -e '
      const assert = require("node:assert/strict");
      const sharp = require("${components.cua_node}/lib/node_modules/sharp");
      sharp({ create: { width: 1, height: 1, channels: 3, background: "red" } })
        .png()
        .toBuffer()
        .then(buffer => assert(buffer.length > 0))
        .catch(error => { console.error(error); process.exitCode = 1; });
      const { ClassicLevel } = require("${components.cua_node}/lib/node_modules/classic-level");
      const database = new ClassicLevel(process.env.TMPDIR + "/level");
      (async () => {
        await database.put("key", "value");
        assert.equal(await database.get("key"), "value");
        await database.close();
      })().catch(error => { console.error(error); process.exitCode = 1; });
    '
    ${components.tectonic}/tectonic --version
    touch "$out"
  '';
}
