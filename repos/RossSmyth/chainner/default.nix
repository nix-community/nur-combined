{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  stdenvNoCC,
  npmHooks,
  nodejs,
  electron,
  zip,
  patch-package,
  breakpointHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "chainner";
  version = "0.25.1";

  src = fetchFromGitHub {
    owner = "chainner-org";
    repo = "chainner";
    tag = "v" + finalAttrs.version;
    hash = "sha256-ZbiccumYprwm/1BOCLxx8sUoqFhfDIHQei61yAmp+h0=";
  };

  patches = [
    ./lockfile.patch
  ];

  postPatch = ''
    rm -rf patches
  '';

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
    zip
    patch-package
    breakpointHook
  ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src patches;
    hash = "sha256-fbv0KZC5rBDQYPQokYI7ay4tmr2j2LLZvmTRA/ySnTU=";
    npmDepsFetcherVersion = 2;
  };

  makeCacheWritable = true;
  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = true;
    CI = true;
  };

  preBuild = ''
    electronTemp="$(mktemp -d)"

    cp -r "${electron.dist}" "$electronTemp/electron-dist"
    chmod -R u+w "$electronTemp/electron-dist"

    pushd "$electronTemp/electron-dist"
    zip -0Xqr "../electron.zip" .
    popd

  '';

  buildPhase = ''
    runHook preBuild

    npm run make -- \
      --arch ${stdenvNoCC.hostPlatform.node.arch} \
      --platform ${stdenvNoCC.hostPlatform.node.platform} \
      --targets "@electron-forge/maker-zip"

    runHook postBuild
  '';
})
