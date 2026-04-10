{ fetchFromGitHub, fetchPnpmDeps, gnumake, lib, nodejs, node-gyp, pkg-config
, pnpm, pnpmConfigHook, python3, sqlite, stdenv, }:

stdenv.mkDerivation (finalAttrs: {
  pname = "obsidian-headless";
  version = "0-unstable-2026-03-22";
  rev = "5f51535b744625ee2cf47d61f704d4d9276590b7";

  src = fetchFromGitHub {
    owner = "obsidianmd";
    repo = "obsidian-headless";
    rev = "${finalAttrs.rev}";
    hash = "sha256-RnLiCbAgetMO8pXYNjNW7fPeR8O7/Zz2i/x5OXOL+8U=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
    python3
    pkg-config
    gnumake
    stdenv.cc
    node-gyp
  ];

  buildInputs = [ sqlite ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-9XbLTX0ZM7GzRkNQ0IIKjuU7dIzzz3WvqfbBOFdIdmY=";
  };

  buildPhase = ''
    runHook preBuild
    pushd node_modules/.pnpm/better-sqlite3@12.6.2/node_modules/better-sqlite3
    node-gyp rebuild
    popd
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/obsidian-headless
    cp -r cli.js node_modules package.json $out/lib/node_modules/obsidian-headless/
    [ -d btime ] && cp -r btime $out/lib/node_modules/obsidian-headless/
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/obsidian-headless/cli.js $out/bin/ob
    chmod +x $out/bin/ob
    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description =
      "Headless client for Obsidian Sync. Sync your vaults from the command line without the desktop app. ";
    homepage = "https://obsidian.md/sync";
    license = lib.licenses.unfree;
    mainProgram = "ob";
  };
})
