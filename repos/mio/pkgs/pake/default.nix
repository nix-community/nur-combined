{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs_22,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm,
  makeWrapper,
  node-gyp,
  pkg-config,
  python3,
  vips,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pake";
  version = "3.7.7";

  src = fetchFromGitHub {
    owner = "tw93";
    repo = "Pake";
    rev = "838cc932ffd1db6bc5ca81ced64f73bcd8568175";
    hash = "sha256-sEjj0a9aGCwv5EFn7PWkYU1j3U5MLO7lj0qL2CkfKOM=";
  };

  nativeBuildInputs = [
    nodejs_22
    pnpmConfigHook
    pnpm
    makeWrapper
    node-gyp
    pkg-config
    python3
  ];

  buildInputs = [ vips ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-gW29F1FDCnMU8l4f22HnDhsX8tkmeel5Fj60YYHLMMk=";
  };

  env = {
    npm_config_build_from_source = "true";
    NPM_CONFIG_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";
  };

  preConfigure = ''
    export HOME=$TMPDIR
    export XDG_CACHE_HOME=$TMPDIR/cache
    mkdir -p "$XDG_CACHE_HOME"
  '';

  postPatch = ''
    # Avoid pnpm trying to self-manage the version (network access) in the build.
    sed -i '/"packageManager":/d' package.json
  '';

  buildPhase = ''
    runHook preBuild

    pnpm config set nodedir ${nodejs_22}
    pnpm install --offline --frozen-lockfile
    pnpm run cli:build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/pake
    mkdir -p $out/bin
    mv * $out/lib/node_modules/pake/
    makeWrapper ${lib.getExe nodejs_22} $out/bin/pake \
      --add-flags "$out/lib/node_modules/pake/dist/cli.js" \
      --set NODE_PATH "$out/lib/node_modules/pake/node_modules"

    runHook postInstall
  '';

  meta = {
    description = "Turn any webpage into a desktop app with one command";
    homepage = "https://github.com/tw93/Pake";
    license = lib.licenses.mit;
    mainProgram = "pake";
    platforms = lib.platforms.linux;
  };
})
