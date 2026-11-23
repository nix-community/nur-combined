{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  wrapGAppsHook3,
  gtk3,
  glib,
  gdk-pixbuf,
  pango,
  cairo,
  librsvg,
  glib-networking,
  aws-lc,
  sqlite,
  zstd,
  libsoup_3,
  webkitgtk_4_1,
}:

let
  version = "3.5.0";
in
rustPlatform.buildRustPackage {
  pname = "arnis";
  inherit version;

  src = fetchFromGitHub {
    owner = "louis-e";
    repo = "arnis";
    tag = "v${version}";
    hash = "sha256-nKkVIzSdcmT/2+ttZodQ/zqWgmECLinZzkuf5HvVnKI=";
  };

  cargoHash = "sha256-m8sFlnHSKCIxjriyQF97+noti/esfAU4t1xn7ukG+8g=";

  # Upstream notes that the test suite needs internet access, which the build
  # sandbox does not have.
  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    # Tauri's Linux webview (webkit2gtk crate).
    webkitgtk_4_1
    libsoup_3
    # The GUI is a GTK app; the wrapper hook sets up its icon and module paths.
    gtk3
    glib
    gdk-pixbuf
    pango
    cairo
    librsvg
    glib-networking
    # rustls uses aws-lc, while rusqlite and zstd are linked through pkg-config
    # by the Rust setup hook (the crates' bundled/vendored copies are unused).
    aws-lc
    sqlite
    zstd
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Generate any location from the real world in Minecraft Java Edition with a high level of detail";
    homepage = "https://github.com/louis-e/arnis";
    license = lib.licenses.asl20;
    mainProgram = "arnis";
    platforms = lib.platforms.linux;
  };
}
