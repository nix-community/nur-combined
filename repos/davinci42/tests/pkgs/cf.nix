{
  pkgs ? import <nixpkgs> { },
  package ? (import ../../default.nix { inherit pkgs; }).cf,
}:
let
  overridden = package.overrideAttrs {
    version = "1.0.0-beta.15";
    __intentionallyOverridingVersion = true;
  };
in
assert package.src.tag == "cf@${package.version}";
assert overridden.src.tag == "cf@1.0.0-beta.15";
assert
  package.meta.platforms == [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
assert builtins.elem "cf" (builtins.attrNames (import ../../default.nix { pkgs = null; }));
pkgs.runCommand "cf-packaging-check"
  {
    nativeBuildInputs = [ pkgs.nodejs_24 ];
  }
  ''
    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$HOME/config"
    export XDG_CACHE_HOME="$HOME/cache"
    export CI=1
    export DO_NOT_TRACK=1
    mkdir -p "$HOME"
    test -x ${package}/bin/cf
    test -x ${package}/bin/cloudflare
    ${package}/bin/cf --version > version.txt
    grep -F ${pkgs.lib.escapeShellArg package.version} version.txt
    ${package}/bin/cloudflare --version > alias-version.txt
    cmp version.txt alias-version.txt
    ${package}/bin/cf --help > /dev/null
    ${package}/bin/cf zones list --help > /dev/null
    ${package}/bin/cf cli search "list zones" > search.txt
    grep -F 'zones' search.txt
    node --experimental-import-meta-resolve --input-type=module <<'EOF'
    import assert from 'node:assert/strict';
    import { createRequire } from 'node:module';
    const manifest = 'file://${package}/lib/cf/package.json';
    const require = createRequire(manifest);
    for (const name of Object.keys(require('./package.json').dependencies)) {
      await import(import.meta.resolve(name, manifest));
    }
    const { Miniflare } = await import(require.resolve('miniflare'));
    const worker = new Miniflare({
      workers: [{
        config: {
          name: 'cf-package-check',
          compatibilityDate: '2026-10-01',
          manifest: {
            mainModule: 'index.js',
            modules: {
              'index.js': {
                type: 'esm',
                contents: 'export default { fetch() { return new Response("cf-package-ok"); } }',
              },
            },
          },
        },
      }],
      host: '127.0.0.1',
      port: 0,
    });
    try {
      const response = await worker.dispatchFetch('http://localhost/');
      assert.equal(await response.text(), 'cf-package-ok');
    } finally {
      await worker.dispose();
    }
    EOF
    touch "$out"
  ''
