{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchNpmDeps,
  npmHooks,
  nodejs,
  wails,
  webkitgtk_4_1,
  pkg-config,
  copyDesktopItems,
  makeDesktopItem,
  autoPatchelfHook,
  nix-update-script,
  xorg,
  stdenv,
  gtk4,
  libsoup_3,
  gtk3,
  glib-networking,
  gsettings-desktop-schemas,
}:

buildGoModule (finalAttrs: rec {
  pname = "lampghost-dev";
  version = "0.3.0-unstable-2025-08-23";

  src = fetchFromGitHub {
    owner = "Catizard";
    repo = "lampghost";
    rev = "d667126547fdfc13976c45f1b14b42410288a6c6";
    hash = "sha256-d03dfloGB3fMZun59n5uYfNZuHEhobJEpTyfTRG9PoY=";
  };

  vendorHash = "sha256-5wPllsqYm26gl49fynuRnCKNCASHQtKK07p0zf+SBhA=";

  env = {
    CGO_ENABLED = 1;
    npmDeps = fetchNpmDeps {
      src = "${finalAttrs.src}/frontend";
      hash = "sha256-YYF6RfA3uE65QdwuJMV+NSvGYtmZRxwrVbQtijNyHRE=";
    };
    npmRoot = "frontend";
  };

  nativeBuildInputs = [
    wails
    pkg-config
    autoPatchelfHook
    nodejs
    npmHooks.npmConfigHook
    copyDesktopItems
    # Ensure pkg-config in strict deps setups finds webkit2gtk-4.1.pc
    webkitgtk_4_1
    webkitgtk_4_1.dev
    gtk4
    gtk4.dev
    libsoup_3
    libsoup_3.dev
    gtk3
    gtk3.dev
    glib-networking
    gsettings-desktop-schemas
  ];

  buildInputs = [
    webkitgtk_4_1
    webkitgtk_4_1.dev
    gtk4
    gtk4.dev
    libsoup_3
    libsoup_3.dev
  ]
  ++ lib.optionals stdenv.isLinux [
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
    xorg.libXxf86vm
  ];

  buildPhase = ''
    runHook preBuild

    export PKG_CONFIG_LIBDIR="${
      lib.makeSearchPath "lib/pkgconfig" [
        webkitgtk_4_1.dev
        gtk4.dev
        libsoup_3.dev
      ]
    }:${
      lib.makeSearchPath "share/pkgconfig" [
        webkitgtk_4_1.dev
        gtk4.dev
        libsoup_3.dev
      ]
    }"
    export PKG_CONFIG_PATH="$PKG_CONFIG_LIBDIR:$PKG_CONFIG_PATH"

    export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
    export GIO_MODULE_DIR="${glib-networking}/lib/gio/modules/"

    wails build -m -trimpath -devtools -tags webkit2_41 -o ${pname}

    runHook postBuild
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "${pname}";
      exec = "${pname}";
      desktopName = "LampGhost (Dev Version)";
      comment = "Offline & Cross-platform beatoraja lamp viewer and more";
      categories = [ "Game" ];
      startupNotify = true;
      keywords = [ "beatoraja" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    install -Dm0755 build/bin/${pname} $out/bin/${pname}

    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script {
      attrPath = "${pname}";
      extraArgs = [
        "--version=branch"
      ];
    };
  };

  meta = {
    description = "Offline & Cross-platform beatoraja lamp viewer and more";
    homepage = "https://github.com/Catizard/lampghost";
    changelog = "https://github.com/Catizard/lampghost/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "${pname}";
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
