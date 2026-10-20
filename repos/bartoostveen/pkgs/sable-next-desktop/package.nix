{
  lib,
  rustPlatform,
  sable-next,
  pkg-config,
  cargo-tauri,
  wrapGAppsHook3,
  makeBinaryWrapper,
  atk,
  cairo,
  dbus,
  gdk-pixbuf,
  glib,
  gtk3,
  libsoup_3,
  libxkbcommon,
  pango,
  pipewire,
  rust-jemalloc-sys,
  sqlite,
  webkitgtk_4_1,
  xz,
  stdenv,
  wayland,
  jq,
  moreutils,
  xdg-utils,
  libayatana-appindicator,
  gst_all_1,
  libGL,
  desktop-file-utils,
  cacert,
  conf ? { },
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sable-next-desktop";
  inherit (sable-next.unwrapped)
    version
    src
    cargoDeps
    ;

  __structuredAttrs = true;
  strictDeps = true;

  buildNoDefaultFeatures = true;
  buildFeatures = [
    "wry"
  ];

  tauriBuildFlags = [
    "--no-sign"
  ];

  postPatch =
    let
      sable' = sable-next.override { inherit conf; };
    in
    ''
      ${lib.getExe jq} \
        '.build.frontendDist = "${sable'}"| del(.build.beforeBuildCommand) | .bundle.createUpdaterArtifacts = false' src-tauri/tauri.conf.json \
        | ${lib.getExe' moreutils "sponge"} src-tauri/tauri.conf.json
    '';

  nativeBuildInputs = [
    cargo-tauri.hook
    rustPlatform.bindgenHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
    wrapGAppsHook3
    desktop-file-utils
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    makeBinaryWrapper
  ];

  buildInputs = [
    atk
    cairo
    dbus
    gdk-pixbuf
    glib
    gtk3
    libayatana-appindicator
    libsoup_3
    libxkbcommon
    pango
    pipewire
    rust-jemalloc-sys
    sqlite
    webkitgtk_4_1
    xz
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
  ])
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland
  ];

  env.LIBSQLITE3_SYS_USE_PKG_CONFIG = true;

  postInstall = ''
    mv $out/bin/app $out/bin/sable
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p "$out/bin"
    makeWrapper "$out/Applications/SableNext.app/Contents/MacOS/SableNext" "$out/bin/sable"
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    desktop-file-edit \
      --set-key="Exec" --set-value="$out/bin/sable" \
      --set-key="StartupWMClass" --set-value="sable" \
      --set-comment "${finalAttrs.meta.description}" \
      --set-key="Categories" --set-value="Network;InstantMessaging;" \
      "$out/share/applications/Sable v2.desktop"
  '';

  nativeCheckInputs = [
    cacert
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${
        lib.makeBinPath [
          desktop-file-utils
          xdg-utils
        ]
      }"
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libayatana-appindicator
          libGL
          libxkbcommon
        ]
      }"
    )
  '';

  meta = {
    inherit (sable-next.meta)
      description
      homepage
      changelog
      license
      maintainers
      ;

    mainProgram = "sable";
  };
})
