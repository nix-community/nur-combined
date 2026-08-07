{
  lib,
  stdenv,
  rustPlatform,
  cargo-tauri,
  sable,
  desktop-file-utils,
  wrapGAppsHook3,
  makeBinaryWrapper,
  pkg-config,
  openssl,
  glib-networking,
  webkitgtk_4_1,
  libayatana-appindicator,
  xdg-utils,
  libGL,
  libxkbcommon,
  gst_all_1,
  jq,
  moreutils,
  nix-update-script,
  _experimental-update-script-combinators,
  conf ? { },
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sable-desktop";
  inherit (sable.unwrapped) version src;

  __structuredAttrs = true;
  strictDeps = true;

  sourceRoot = "${finalAttrs.src.name}/src-tauri";

  cargoHash = "sha256-XKKdGdOu4coJpyU3VamT8j6gQN1NFsXlKcfN/Hl2gsE=";

  buildNoDefaultFeatures = true;
  buildFeatures = [
    "wry"
  ];

  tauriBuildFlags = [
    "--no-sign"
  ];

  patches = [
    ./0001-tauri-do-not-regenerate-typescript-bindings.patch
    ./0002-tauri-disable-deeplinking.patch
  ];

  postPatch =
    let
      sable' = sable.override {
        conf = {
          allowCustomHomeservers = true;
        }
        // conf
        // {
          hashRouter.enabled = true;
        };
      };
    in
    ''
      ${lib.getExe jq} \
        '.build.frontendDist = "${sable'}"| del(.build.beforeBuildCommand) | .bundle.createUpdaterArtifacts = false | del(.plugins.typegen)' tauri.conf.json \
        | ${lib.getExe' moreutils "sponge"} tauri.conf.json
    '';

  postInstall =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p "$out/bin"
      makeWrapper "$out/Applications/Sable.app/Contents/MacOS/Sable" "$out/bin/sable"
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      desktop-file-edit \
        --set-comment "An almost stable Matrix client for desktop" \
        --set-key="Categories" --set-value="Network;InstantMessaging;" \
        $out/share/applications/Sable.desktop
    '';

  nativeBuildInputs = [
    cargo-tauri.hook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    desktop-file-utils
    pkg-config
    wrapGAppsHook3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    makeBinaryWrapper
  ];

  buildInputs = [
    glib-networking
    openssl
    webkitgtk_4_1
    libayatana-appindicator
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
  ]);

  checkFlags = [
    # These both depend on exporting types at runtime for some reason
    "--skip=desktop::runtime_state::export_bindings_desktopruntimestate"
    "--skip=desktop::settings::export_bindings_desktopsettings"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}"
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libayatana-appindicator
          libGL
          libxkbcommon
        ]
      }"
    )
  '';

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script { attrPath = "sable-unwrapped"; })
    (nix-update-script { })
  ];

  meta = {
    inherit (sable.meta)
      description
      homepage
      changelog
      license
      ;

    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "sable";
    platforms = lib.platforms.all;
  };
})
