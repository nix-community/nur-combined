{
  lib,
  stdenv,
  stdenvNoCC,
  writeShellScriptBin,
  fetchFromGitHub,
  fetchurl,
  nodejs_22,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm,
  makeWrapper,
  node-gyp,
  pkg-config,
  python3,
  vips,
  glib,
  gtk4,
  gtk3,
  gdk-pixbuf,
  pango,
  cairo,
  atk,
  xorg,
  wayland,
  libxkbcommon,
  fontconfig,
  libepoxy,
  fribidi,
  harfbuzz,
  libthai,
  freetype,
  libpng,
  libsoup_3,
  libayatana-indicator,
  ayatana-ido,
  libdbusmenu,
  webkitgtk_4_1,
  glib-networking,
  libayatana-appindicator,
  openssl,
  libsysprof-capture,
  gst_all_1,
}:

let
  appRun = fetchurl {
    url = "https://github.com/tauri-apps/binary-releases/releases/download/apprun-old/AppRun-x86_64";
    hash = "sha256-8wFApDoKWeRtshve/fdJuenyxpRukq+rus+YuK5z+08=";
  };

  linuxdeploy = fetchurl {
    url = "https://github.com/tauri-apps/binary-releases/releases/download/linuxdeploy/linuxdeploy-x86_64.AppImage";
    hash = "sha256-52K+qFyOsNSzUI1G5cHwN/cX0PkwOuO0qvyLBJkfoe8=";
  };

  linuxdeployPluginAppimage = fetchurl {
    url = "https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/continuous/linuxdeploy-plugin-appimage-x86_64.AppImage";
    hash = "sha256-gueLhAZ3TgVqToMmtgaf7DwHoK5Q2TPSAQBRipiaDkc=";
  };

  appimageTools =
    if stdenv.hostPlatform.isx86_64 then
      stdenvNoCC.mkDerivation {
        pname = "pake-appimage-tools";
        version = "2026-01-11";
        dontUnpack = true;
        installPhase = ''
          install -Dm755 ${appRun} $out/AppRun-x86_64
          install -Dm755 ${linuxdeploy} $out/linuxdeploy-x86_64.AppImage
          install -Dm755 ${linuxdeployPluginAppimage} $out/linuxdeploy-plugin-appimage.AppImage
        '';
      }
    else
      null;

  pakePkgConfig = writeShellScriptBin "pkg-config" ''
    if [ "$1" = "--libs-only-L" ]; then
      case "$2" in
        ayatana-appindicator3-0.1|appindicator3-0.1)
          echo "-L${libayatana-appindicator}/lib"
          exit 0
          ;;
      esac
    fi

    exec ${pkg-config}/bin/pkg-config "$@"
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "pake";
  version = "3.7.2-unstable-20260114";

  src = fetchFromGitHub {
    owner = "tw93";
    repo = "Pake";
    rev = "838cc932ffd1db6bc5ca81ced64f73bcd8568175";
    hash = "sha256-sEjj0a9aGCwv5EFn7PWkYU1j3U5MLO7lj0qL2CkfKOM=";
  };

  patches = [
    ./runtime-dir.patch
  ];

  nativeBuildInputs = [
    nodejs_22
    pnpmConfigHook
    pnpm
    makeWrapper
    node-gyp
    pkg-config
    python3
  ];

  buildInputs = [
    vips
  ];

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
      --add-flags "--targets deb" \
      ${lib.optionalString (appimageTools != null) "--set PAKE_APPIMAGE_TOOLS_DIR ${appimageTools} \\"}
      --set NODE_PATH "$out/lib/node_modules/pake/node_modules" \
      --set PKG_CONFIG ${pakePkgConfig}/bin/pkg-config \
      --set-default PAKE_SKIP_INSTALL 1 \
      --prefix PATH : ${
        lib.makeBinPath [
          pakePkgConfig
          pkg-config
        ]
      } \
      --set PKG_CONFIG_PATH ${
        lib.makeSearchPath "lib/pkgconfig" [
          (lib.getDev glib)
          (lib.getDev gtk3)
          (lib.getDev gtk4)
          (lib.getDev gdk-pixbuf)
          (lib.getDev pango)
          (lib.getDev cairo)
          (lib.getDev atk)
          (lib.getDev xorg.libX11)
          (lib.getDev xorg.libXext)
          (lib.getDev xorg.libXi)
          (lib.getDev xorg.libXrandr)
          (lib.getDev xorg.libXcursor)
          (lib.getDev xorg.libXfixes)
          (lib.getDev xorg.libXcomposite)
          (lib.getDev xorg.libXdamage)
          (lib.getDev xorg.libXinerama)
          (lib.getDev wayland)
          (lib.getDev libxkbcommon)
          (lib.getDev fontconfig)
          (lib.getDev libepoxy)
          (lib.getDev fribidi)
          (lib.getDev harfbuzz)
          (lib.getDev libthai)
          (lib.getDev freetype)
          (lib.getDev libpng)
          (lib.getDev xorg.libXrender)
          (lib.getDev xorg.libXft)
          (lib.getDev libsoup_3)
          (lib.getDev libayatana-indicator)
          (lib.getDev ayatana-ido)
          (lib.getDev libdbusmenu)
          (lib.getDev webkitgtk_4_1)
          (lib.getDev glib-networking)
          (lib.getDev libayatana-appindicator)
          (lib.getDev openssl)
          (lib.getDev libsysprof-capture)
          (lib.getDev gst_all_1.gst-plugins-base)
          (lib.getDev gst_all_1.gst-plugins-bad)
          (lib.getDev gst_all_1.gst-plugins-good)
          (lib.getDev gst_all_1.gst-plugins-rs)
        ]
      } \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libayatana-appindicator
        ]
      }

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
