{
  runCommand,
  fetchFromGitHub,
  lib,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  electron,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  stdenv,
  python3,
  removeReferencesTo,
  yt-dlp,
  ffmpeg,
}:

let
  pname = "vidbee";

  version = "1.3.10";

  baseSrc = fetchFromGitHub {
    owner = "nexmoe";
    repo = "VidBee";
    tag = "v${version}";
    hash = "sha256-7gzs12EE8fIX482OQUorBjFeigcxPlJpoIx/AjpLcg0=";
  };

  src = runCommand "vidbee-src" { } ''
    mkdir -p $out
    cp -r ${baseSrc}/* $out/
    chmod -R +w $out
    cp ${./package.json} $out/package.json
    cp ${./pnpm-lock.yaml} $out/pnpm-lock.yaml
  '';

in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version src;

  pnpmDeps = fetchPnpmDeps {
    pname = finalAttrs.pname;
    inherit (finalAttrs) version src;
    pnpm = pnpm_10;
    hash = "sha256-7yWkkHta+eBDsN0LF/37UkhmPBDGs5yfucg5QuqFkuQ=";
    fetcherVersion = 3;
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_10
    makeWrapper
    copyDesktopItems
    (python3.withPackages (ps: [ ps.setuptools ]))
  ];

  buildInputs = [
    electron
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  };

  # Patch for Nix packaging compatibility
  # These patches address assumptions about filesystem layout that don't hold in Nix:
  # 1. Electron's process.resourcesPath points to Electron's resources, not app's
  # 2. Nix store is read-only, so chmod fails on bundled binaries
  # TODO: Upstream PR to make these configurable via env vars
  postPatch = ''
    # Override resource path resolution with NIX_VIDBEE_RESOURCES env var
    # This is patched at the variable usage sites since the app doesn't have
    # a centralized resource path getter
    substituteInPlace apps/desktop/src/main/lib/ytdlp-manager.ts \
      --replace-fail 'process.resourcesPath' \
      '((process.env.NIX_VIDBEE_RESOURCES) || process.resourcesPath)'

    substituteInPlace apps/desktop/src/main/lib/ffmpeg-manager.ts \
      --replace-fail 'process.resourcesPath' \
      '((process.env.NIX_VIDBEE_RESOURCES) || process.resourcesPath)'

    substituteInPlace apps/desktop/src/main/lib/database/migrate.ts \
      --replace-fail 'process.resourcesPath' \
      '((process.env.NIX_VIDBEE_RESOURCES) || process.resourcesPath)'

    # Skip chmod on read-only Nix store
    # The binaries are already executable in our derivation
    substituteInPlace apps/desktop/src/main/lib/ytdlp-manager.ts \
      --replace-fail 'fs.chmodSync(bundledPath, 0o755)' \
      'try { fs.chmodSync(bundledPath, 0o755) } catch {}'

    substituteInPlace apps/desktop/src/main/lib/ffmpeg-manager.ts \
      --replace-fail 'fs.chmodSync(ffmpegPath, 0o755)' \
      'try { fs.chmodSync(ffmpegPath, 0o755) } catch {}'

    substituteInPlace apps/desktop/src/main/lib/ffmpeg-manager.ts \
      --replace-fail 'fs.chmodSync(ffprobePath, 0o755)' \
      'try { fs.chmodSync(ffprobePath, 0o755) } catch {}'
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "vidbee";
      desktopName = "VidBee";
      comment = "A modern Electron application for downloading videos and audios";
      exec = "vidbee";
      categories = [ "Utility" ];
      mimeTypes = [ "x-scheme-handler/vidbee" ];
    })
  ];

  buildPhase = ''
    runHook preBuild

    # Install dependencies
    pnpm install --offline --frozen-lockfile

    # Compile better-sqlite3 native module for Electron
    for f in $(find . -path '*/node_modules/better-sqlite3' -type d); do
      (cd "$f" && (
        npm run build-release --offline --nodedir="${electron.headers}"
        rm -rf build/Release/{.deps,obj,obj.target,test_extension.node}
        find build -type f -exec ${lib.getExe removeReferencesTo} -t "${electron.headers}" {} \;
      ))
    done

    # Build the application
    pnpm run build

    # Remove dev dependencies to reduce closure size
    # Use --ignore-scripts to skip prepare scripts (husky)
    CI=true pnpm prune --prod=false --ignore-scripts

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Create the standard Electron app structure:
    # $out/lib/vidbee/
    #   app/         <- main app code
    #   resources/   <- bundled resources (yt-dlp, ffmpeg, drizzle)
    #
    # When launched: electron $out/lib/vidbee/app
    # process.resourcesPath = $out/lib/vidbee (parent of app directory)
    # But we override with NIX_VIDBEE_RESOURCES

    mkdir -p $out/lib/vidbee/app
    mkdir -p $out/lib/vidbee/resources

    # Copy build outputs - keep the out/ structure
    cp -r apps/desktop/out $out/lib/vidbee/app/

    # Copy package.json
    cp apps/desktop/package.json $out/lib/vidbee/app/

    # Copy node_modules
    cp -r node_modules $out/lib/vidbee/app/

    # Copy resources
    # Use install command for proper permission handling
    cp -r apps/desktop/resources/drizzle $out/lib/vidbee/resources/

    install -Dm755 ${yt-dlp}/bin/yt-dlp \
      $out/lib/vidbee/resources/yt-dlp_linux

    install -Dm755 ${ffmpeg}/bin/ffmpeg \
      $out/lib/vidbee/resources/ffmpeg/ffmpeg

    install -Dm755 ${ffmpeg}/bin/ffprobe \
      $out/lib/vidbee/resources/ffmpeg/ffprobe

    # Create wrapper
    # Pass app path directly to electron
    # Set NIX_VIDBEE_RESOURCES to override the default resources path
    # Note: code adds "/resources" suffix, so we point to parent directory
    makeWrapper "${electron}/bin/electron" "$out/bin/vidbee" \
      --inherit-argv0 \
      --set ELECTRON_IS_DEV 0 \
      --set NIX_VIDBEE_RESOURCES $out/lib/vidbee \
      --add-flags "$out/lib/vidbee/app" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime}}"

    # Remove broken symlinks from pnpm workspace
    find $out/lib/vidbee/app/node_modules -xtype l -delete

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "A modern Electron application for downloading videos and audios";
    homepage = "https://github.com/nexmoe/VidBee";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lonerOrz ];
    platforms = lib.platforms.linux;
    mainProgram = "vidbee";
  };
})
