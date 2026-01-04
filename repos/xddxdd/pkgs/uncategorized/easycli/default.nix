{
  lib,
  sources,
  rustPlatform,
  pkg-config,
  openssl,
  webkitgtk_4_1,
  glib-networking,
  cargo-tauri,
  wrapGAppsHook3,
  libsoup_3,
  copyDesktopItems,
  makeDesktopItem,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources.easycli) pname version src;

  sourceRoot = "source/src-tauri";

  cargoHash = "sha256-VMFnljXsQHjd7vjFPN7oQIkbkR2zV7HuLNl9r/r/VjM=";

  nativeBuildInputs = [
    pkg-config
    cargo-tauri
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    openssl
    webkitgtk_4_1
    glib-networking
    libsoup_3
  ];

  preConfigure = ''
    pushd ..
    chmod -R +w .
    mkdir -p dist-web
    cp login.html settings.html dist-web/
    cp -r js css dist-web/
    popd

    mkdir -p icons
    cp ../images/icon.png icons/
  '';

  doCheck = false;

  desktopItems = [
    (makeDesktopItem {
      name = "easycli";
      exec = "easycli";
      icon = "easycli";
      desktopName = "EasyCLI";
      comment = finalAttrs.meta.description;
      categories = [ "Utility" ];
    })
  ];

  postInstall = ''
    install -Dm644 icons/icon.png $out/share/pixmaps/easycli.png
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Desktop GUI from CLIProxyAPI";
    homepage = "https://github.com/router-for-me/EasyCLI";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "easycli";
  };
})
