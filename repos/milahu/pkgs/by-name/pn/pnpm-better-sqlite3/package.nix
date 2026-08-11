# https://stackoverflow.com/questions/79498809
# NixOS: Installing a package which uses `prebuild-install` in `mkDerivation` with PNPM

{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpm,
  pnpmConfigHook,
  python3,
  node-gyp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pnpm-better-sqlite3";
  version = "0-unstable-2025-03-10";

  src = fetchFromGitHub {
    owner = "MartinRamm";
    repo = "pnpm-better-sqlite3";
    rev = "671285f2591c81295ed8f1d27e97c787b46ae74b";
    hash = "sha256-cWnOLBqy3jLOR1hkLA28aOeHu0EGPGE8+4HLdnU26T0=";
  };

  buildInputs = [
    # for patchShebangs
    nodejs
  ];

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
    python3 # for node-gyp
    node-gyp
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-m6BQkxHCkOHP8x9y4Jx/1MVb0c1X6Hdc7RJKgcjT2do=";
  };

  buildPhase = ''
    pushd node_modules/better-sqlite3
    # no. gyp ERR! stack FetchError: request to https://nodejs.org/download/release/v24.14.1/node-v24.14.1-headers.tar.gz failed
    # npm run build-release
    # fix: call node-gyp from nativeBuildInputs
    node-gyp rebuild --release
    # prune build files: 32MB -> 2MB
    mv build/Release/better_sqlite3.node .
    rm -rf build deps 
    mkdir -p build/Release
    mv better_sqlite3.node build/Release
    popd

    # create a test script
    cat >test.mjs <<'EOF'
    #!/usr/bin/env node
    // https://github.com/WiseLibs/better-sqlite3#usage
    import Database from 'better-sqlite3';
    const db = new Database(':memory:');
    db.exec('CREATE TABLE users (id INTEGER, name TEXT)');
    db.exec("INSERT INTO users (id, name) VALUES (0, 'root')");
    const userId = 0;
    const row = db.prepare('SELECT * FROM users WHERE id = ?').get(userId);
    console.log(`''${row.id} ''${row.name}`); // expected: "0 root"
    EOF
    chmod +x test.mjs
    patchShebangs test.mjs
  '';

  doCheck = true;

  checkPhase = ''
    echo checking better-sqlite3
    echo "expected: 0 root"
    echo "actual: $(./test.mjs)"
  '';

  installPhase = ''
    mkdir -p $out/lib/node_modules
    cp -r . $out/lib/node_modules/${finalAttrs.pname}
    mkdir -p $out/bin
    ln -sr $out/lib/node_modules/${finalAttrs.pname}/test.mjs $out/bin/${finalAttrs.pname}-test
  '';

  meta = {
    description = "";
    homepage = "https://github.com/MartinRamm/pnpm-better-sqlite3";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ ];
    # mainProgram = "pnpm-better-sqlite3";
    platforms = lib.platforms.all;
  };
})
