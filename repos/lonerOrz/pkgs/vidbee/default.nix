{
  fetchFromGitHub,
  lib,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  electron,
  makeWrapper,
  makeDesktopItem,
  stdenv,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vidbee";

  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "nexmoe";
    repo = "VidBee";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zZ5t9s2MV6HdUElx0Ef1VMR3RyZT71YcfpkS9ydK1tY=";
  };

  pnpmDeps = fetchPnpmDeps {
    pname = finalAttrs.pname;
    inherit (finalAttrs) version src;
    pnpm = pnpm_10;
    hash = "sha256-gqiSSdDc1HIcDTkPipFK4Aytha5Pst5DQQ9s+1me518=";
    fetcherVersion = 3;
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_10
    makeWrapper
    electron
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  };

  desktopItem = makeDesktopItem {
    name = "vidbee";
    desktopName = "VidBee";
    comment = "A modern Electron application for downloading videos and audios";
    exec = "vidbee";
    categories = [ "Utility" ];
  };

  buildPhase = ''
    runHook preBuild

    # Use --ignore-scripts to skip postinstall (no network in Nix build)
    pnpm install --offline --frozen-lockfile --ignore-scripts

    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Copy the built application to lib directory
    mkdir -p $out/lib/vidbee
    cp -r out/* $out/lib/vidbee/

    # Copy node_modules
    cp -r node_modules $out/lib/vidbee/

    # Create wrapper - follow nixpkgs electron pattern
    makeWrapper "${electron}/bin/electron" "$out/bin/vidbee" \
      --inherit-argv0 \
      --set ELECTRON_IS_DEV 0 \
      --set ELECTRON_RESOURCES_PATH $out/lib/vidbee \
      --set NODE_PATH $out/lib/vidbee/node_modules \
      --add-flags $out/lib/vidbee/main/index.js \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    # Install desktop file
    install -m 444 -D "${finalAttrs.desktopItem}/share/applications/"* \
        -t $out/share/applications/

    runHook postInstall
  '';

  meta = {
    description = "A modern Electron application for downloading videos and audios";
    homepage = "https://github.com/nexmoe/VidBee";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lonerOrz ];
    platforms = lib.platforms.linux;
    mainProgram = "vidbee";
  };
})
