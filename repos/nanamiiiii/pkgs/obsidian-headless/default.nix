{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs_22,
  srcOnly,
  node-gyp,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  makeWrapper,
  python3,
  cctools,
}:

let
  nodeSources = srcOnly nodejs_22;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "obsidian-headless";
  version = "0.0.11";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "obsidianmd";
    repo = "obsidian-headless";
    tag = "${finalAttrs.version}";
    hash = "sha256-zjMdOCuOMMvBZhrXf7nkz8sYAQ0vU+TzyHhlwIbEfHU=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      postPatch
      ;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-9XbLTX0ZM7GzRkNQ0IIKjuU7dIzzz3WvqfbBOFdIdmY=";
  };

  nativeBuildInputs = [
    nodejs_22
    node-gyp
    pnpmConfigHook
    pnpm_10
    makeWrapper
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools.libtool
  ];

  postPatch = ''
    cp ${./pnpm-lock.yaml} ./pnpm-lock.yaml
  '';

  buildPhase = ''
    runHook preBuild

    pushd node_modules/better-sqlite3
    npm run build-release --offline "--nodedir=${nodeSources}"
    mv build/Release/better_sqlite3.node .
    rm -rf build
    mkdir -p build/Release
    mv better_sqlite3.node build/Release/
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/obsidian-headless
    cp -r cli.js btime node_modules package.json $out/lib/obsidian-headless/

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs_22} $out/bin/ob \
      --add-flags $out/lib/obsidian-headless/cli.js

    runHook postInstall
  '';

  meta = {
    description = "Headless client for Obsidian Sync and Obsidian Publish. Sync and publish your vaults from the command line without the desktop app";
    homepage = "https://github.com/obsidianmd/obsidian-headless";
    license = lib.licenses.unlicense;
    mainProgram = "ob";
  };
})
