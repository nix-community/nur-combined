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
  version = "0.3.1-unstable-2025-09-10";

  src = fetchFromGitHub {
    owner = "Catizard";
    repo = "lampghost";
    rev = "c831a34bad3e4743f88a2e87ffee39614731107f";
    hash = "sha256-Ok4dP4I1UJrJNcc+iMt58r4xpV5siH5b1aEcgVZ/beY=";
  };

  vendorHash = "sha256-b2nWUsZjdNR2lmY9PPEhba/NsOn1K4nLDZhv71zxAK8=";

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
