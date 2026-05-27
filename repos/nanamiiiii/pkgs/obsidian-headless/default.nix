{
  darwin,
  fetchFromGitHub,
  fetchPnpmDeps,
  gnumake,
  lib,
  nodejs,
  node-gyp,
  pkg-config,
  pnpm,
  pnpmConfigHook,
  python3,
  sqlite,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obsidian-headless";
  version = "0-unstable-2026-05-27";
  rev = "42422908098f4b1a034d5035b411bcbd1e5d1671";

  src = fetchFromGitHub {
    owner = "obsidianmd";
    repo = "obsidian-headless";
    rev = "${finalAttrs.rev}";
    hash = "sha256-4MPPxHgrhZ6AOt65a/yI3ECQDv9UHuChUemSHPf+SH0=";
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
  ]
  ++ (lib.optional stdenv.hostPlatform.isDarwin [ darwin.cctools ]);

  buildInputs = [ sqlite ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-mhf9C221F16MwcReWy2UnSqa6jpOqGlH4DPLpu88Jsw=";
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
    description = "Headless client for Obsidian Sync. Sync your vaults from the command line without the desktop app. ";
    homepage = "https://obsidian.md/sync";
    license = lib.licenses.unfree;
    mainProgram = "ob";
  };
})
