{
  lib,
  stdenv,
  callPackage,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs_22,
  pnpm_11,
  cmake,
  pkg-config,
  darwin,
  python3,
  electron,
  nix-update-script,
  symlinkJoin,
  commandLineArgs ? [ ],
}:
let
  pname = "xmcl";

  common = callPackage ./common.nix { };
  inherit (common)
    version
    srcArgs
    desktopItem
    mkLauncher
    installIcons
    meta
    ;

  src = fetchFromGitHub (
    srcArgs // { hash = "sha256-vlTUTywdn1yn7RquR6d7EOCWcmbCRbmgnR/noLBAK4o="; }
  );

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-b9N3VUusRONF3CkNc9Y3YmCGWObO/4/Udz4wS1Xk+X4=";
  };

  patches = [
    ./patches/0001-build-use-nix-electron.patch
    ./patches/0002-esbuild-node-plugin-stub.patch
  ];

  resources = stdenv.mkDerivation {
    pname = "xmcl-resources";
    inherit
      version
      src
      pnpmDeps
      patches
      ;

    nativeBuildInputs = [
      cmake
      nodejs_22
      pkg-config
      pnpm_11
      pnpmConfigHook
      python3
    ]
    ++ lib.optionals stdenv.isDarwin [ darwin.autoSignDarwinBinariesHook ];

    buildInputs = electron.buildInputs ++ lib.optionals stdenv.isLinux common.runtimeLibs;

    dontUseCmakeConfigure = true;

    env = {
      ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
      PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
      COREPACK_ENABLE_STRICT = "0";
      CURSEFORGE_API_KEY = ""; # 回头再修好这个
      npm_config_build_from_source = "true";
      npm_config_nodedir = "${electron.headers}";
    };

    postPatch = ''
      substituteInPlace xmcl-electron-app/main/pluginAutoUpdate.ts \
        --replace-fail "  if (process.env.XMCL_E2E) {" \
                       "  if (process.env.XMCL_E2E || process.env.XMCL_DISABLE_AUTO_UPDATE) {"
    '';

    buildPhase = ''
      runHook preBuild

      export HOME="$TMPDIR/home"
      mkdir -p "$HOME"
      export PATH="$PWD/node_modules/.bin:$PATH"

      printf 'CURSEFORGE_API_KEY=\n' > xmcl-electron-app/.env

      pnpm build:renderer

      ELECTRON_DIST="${electron.dist}" \
      ELECTRON_VERSION="${electron.version}" \
        pnpm build

      runHook postBuild
    '';

    postBuild = ''
      mkdir -p "$out/share/xmcl"

      asar=$(find xmcl-electron-app/build/output -name 'app.asar' -path '*/resources/*' | head -1)
      cp "$asar" "$out/share/xmcl/app.asar"

      ${installIcons "${src}/xmcl-electron-app/icons"}
    '';
  };

  launcher = mkLauncher { inherit resources commandLineArgs; };
in
symlinkJoin {
  inherit pname version;
  paths = [
    resources
    launcher
    desktopItem
  ];

  passthru.updateScript = nix-update-script { };

  meta = meta // {
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
