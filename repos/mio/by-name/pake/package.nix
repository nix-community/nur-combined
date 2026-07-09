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
  rustPlatform,
  makeBinaryWrapper,
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
  libx11,
  libxext,
  libxi,
  libxcursor,
  libxinerama,
  libxrender,
  libxrandr,
  libxfixes,
  libxcomposite,
  libxdamage,
  libxft,
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
    hash = "sha256-HaFqRvpeBYrnQOfDXtDTbYbLhprJzIpf2aGEfXl42Zo=";
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
  version = "3.13.1";

  src = fetchFromGitHub {
    owner = "tw93";
    repo = "Pake";
    rev = "V${finalAttrs.version}";
    hash = "sha256-Wmkt95aorIw4OXWK6ZhkqEBRx+nM/w5zb3srcl882wI=";
  };

  patches = [
    ./runtime-dir.patch
  ];

  nativeBuildInputs = [
    nodejs_22
    pnpmConfigHook
    pnpm
    makeBinaryWrapper
    node-gyp
    pkg-config
    python3
  ];

  buildInputs = [
    vips
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    prePnpmInstall = ''
      sed -i '/^overrides:/,+2d' pnpm-lock.yaml
    '';
    hash = "sha256-QcXyIkhMjHxZ1ZXQOrleaQZqWH+kIL+OOSAk4SBaZXs=";
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
    # pnpm 11 no longer treats package.json's pnpm.overrides as lockfile
    # overrides, so the old lockfile metadata trips frozen installs even though
    # the locked graph itself is usable.
    sed -i '/^overrides:/,+2d' pnpm-lock.yaml
  '';

  buildPhase = ''
    runHook preBuild

    export npm_config_nodedir=${nodejs_22}
    pnpm install --offline --frozen-lockfile

    # pnpmConfigHook renames packageManager for install; restore for cli build.
    substituteInPlace package.json \
      --replace-warn '"_packageManager"' '"packageManager"'

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
      --prefix PKG_CONFIG_PATH : ${
        lib.makeSearchPath "lib/pkgconfig" [
          (lib.getDev glib)
          (lib.getDev gtk3)
          (lib.getDev gtk4)
          (lib.getDev gdk-pixbuf)
          (lib.getDev pango)
          (lib.getDev cairo)
          (lib.getDev atk)
          (lib.getDev libx11)
          (lib.getDev libxext)
          (lib.getDev libxi)
          (lib.getDev libxrandr)
          (lib.getDev libxcursor)
          (lib.getDev libxfixes)
          (lib.getDev libxcomposite)
          (lib.getDev libxdamage)
          (lib.getDev libxinerama)
          (lib.getDev wayland)
          (lib.getDev libxkbcommon)
          (lib.getDev fontconfig)
          (lib.getDev libepoxy)
          (lib.getDev fribidi)
          (lib.getDev harfbuzz)
          (lib.getDev libthai)
          (lib.getDev freetype)
          (lib.getDev libpng)
          (lib.getDev libxrender)
          (lib.getDev libxft)
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

  passthru = {
    cargoDeps = rustPlatform.fetchCargoVendor {
      pname = "pake";
      inherit (finalAttrs) version src;
      cargoRoot = "src-tauri";
      hash = "sha256-dEj0Zo5ioLETtOQolU1fV/RBbMrlhxJgodXt69DTVUE=";
    };
  };

  meta = {
    description = "Turn any webpage into a desktop app with one command";
    homepage = "https://github.com/tw93/Pake";
    license = lib.licenses.mit;
    mainProgram = "pake";
    platforms = lib.platforms.linux;
  };
})
