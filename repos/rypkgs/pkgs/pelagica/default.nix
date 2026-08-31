{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  webkitgtk_6_0,
  glib-networking,
}:

buildGoModule (finalAttrs: {
  pname = "pelagica";
  version = "4.7.0";

  src = fetchFromGitHub {
    owner = "PelagicaApp";
    repo = "pelagica";
    # Upstream tags releases without a `v` prefix.
    tag = finalAttrs.version;
    hash = "sha256-HYRZJEYV2XjqR8pkBol5CxUg1PNfhIFx/LsQH4gIEtk=";
  };

  # The Wails app lives in `desktop/`; the repo root is the pnpm workspace root.
  modRoot = "desktop";
  pnpmRoot = "..";

  # `go mod vendor` fails resolving the Windows-only WebView2 loader embeds in
  # wails; proxying the module cache sidesteps the vendor tree entirely.
  proxyVendor = true;
  vendorHash = "sha256-6RTuwHfmBh6OeCEpa87/27MqlyZm1gs4XnlTzKWv+dU=";

  # The vendor derivation inherits nativeBuildInputs and preBuild, but has no
  # pnpmDeps and no need for the frontend bundle.
  overrideModAttrs = _: {
    dontPnpmConfigure = true;
    preBuild = "";
  };

  # Only the desktop frontend and the shared core package are needed; the tizen,
  # webos and tv-frontend workspaces pull in a large unrelated dependency tree.
  # This must be set on the derivation as well as on fetchPnpmDeps, or the two
  # pnpm invocations disagree about which packages to install.
  pnpmWorkspaces = [
    "pelagica"
    "@pelagica/core"
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;
    pnpm = pnpm_10;
    fetcherVersion = 4;
    hash = "sha256-vu8lo5iXtapHR6dqJs0vk9ZTzVZhCwL0Ijv0xYXHfuA=";
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_10
    nodejs
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    webkitgtk_6_0
    glib-networking
  ];

  env.CGO_ENABLED = 1;

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "." ];

  # `main.go` does `go:embed all:frontend/dist`, so the Vite bundle has to be
  # built and copied into the Go module before the compile starts.
  preBuild = ''
    pushd ..
    pnpm --filter pelagica run build:desktop
    popd

    mkdir -p frontend/dist
    cp -r ../frontend/dist/. frontend/dist/
  '';

  postInstall = ''
    mv $out/bin/pelagica-desktop $out/bin/pelagica

    install -Dm644 build/linux/pelagica.desktop \
      $out/share/applications/pelagica.desktop
    install -Dm644 build/appicon.png \
      $out/share/icons/hicolor/512x512/apps/pelagica.png
  '';

  meta = {
    description = "Modern desktop client for Jellyfin";
    longDescription = ''
      Pelagica is a Jellyfin client built on Wails, with a React frontend
      embedded in a native GTK4/WebKitGTK shell. This package builds the
      desktop application; the same repository also ships web, Tizen and
      webOS targets.
    '';
    homepage = "https://pelagica.app";
    downloadPage = "https://github.com/PelagicaApp/pelagica/releases";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
    mainProgram = "pelagica";
  };
})
