{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  electron,
  python3,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "beam-studio";
  version = "2.6.8-stable";

  src = fetchFromGitHub {
    owner = "flux3dp";
    repo = "beam-studio";
    rev = "refs/tags/app-2.6.8-stable";
    hash = "sha256-gfmIuw3aKDzAFGIDZTs1V/mDIkDWDvdbb+dJ9m0OOeQ=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 4;
    hash = "sha256-4LZ37gYPpFQ/tR/T8R+bdvnp5tHllcdSPwjml9B1uHo=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3
    nodejs
    pnpmConfigHook
    pnpm_10
    copyDesktopItems
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  env.PUBLISH_PATH = "";
  env.PUBLISH_SUFFIX = "";

  buildPhase = ''
    runHook preBuild

    # Patch prebuilt binaries in node_modules
    autoPatchelf node_modules

    # Beam Studio build
    pnpm --filter @beam-studio/app run build
    pnpm --filter @beam-studio/app run build-node

    # Run electron-builder
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    cd apps/app
    pnpm exec electron-builder \
      --dir \
      -c.electronDist=../../electron-dist \
      -c.electronVersion=${electron.version} \
      -c.npmRebuild=false \
      -c.linux.target=dir
    cd ../..

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/beam-studio
    cp -r apps/app/dist/linux-unpacked/locales $out/share/beam-studio/
    cp -r apps/app/dist/linux-unpacked/resources $out/share/beam-studio/
    cp apps/app/dist/linux-unpacked/*.pak $out/share/beam-studio/ || true

    mkdir -p $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/beam-studio \
      --add-flags $out/share/beam-studio/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "beam-studio";
      exec = "beam-studio %U";
      icon = "beam-studio";
      desktopName = "Beam Studio";
      comment = finalAttrs.meta.description;
      categories = [
        "Graphics"
        "Engineering"
      ];
      startupWMClass = "Beam Studio";
    })
  ];

  meta = {
    description = "Beam Studio";
    homepage = "https://github.com/flux3dp/beam-studio";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    mainProgram = "beam-studio";
    platforms = lib.platforms.linux;
  };
})
