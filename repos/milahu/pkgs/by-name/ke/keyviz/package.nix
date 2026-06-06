# based on
# https://github.com/NixOS/nixpkgs/blob/master/doc/hooks/tauri.section.md

{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchNpmDeps,
  fetchurl,
  cargo-tauri,
  glib-networking,
  nodejs,
  npmHooks,
  openssl,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook4,
  libxtst,
  libappindicator,
  gst_all_1,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "keyviz";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "mulaRahul";
    repo = "keyviz";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KgMb09OLyNRBmXY0x5BNg1jsRKq7/0lQWUEvlFgQPNk=";
  };

  cargoHash = "sha256-oaN4018lNCJtBxvVksy3JzMern60QU7yAYOsKQnvWNM=";

  # Assuming our app's frontend uses `npm` as a package manager
  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-gDG5v8ZQBOsUF9+b2/B6V1zIDj0JmAt0+h4/Q/gO8Hw=";
  };

  # fix: called `Option::unwrap()` on a `None` value
  # https://github.com/mulaRahul/keyviz/issues/438
  # https://github.com/tauri-apps/tao/pull/1204
  patch-tao = fetchurl {
    url = "https://github.com/tauri-apps/tao/commit/bb268f5812a111f735da0fbadec0566324528a73.patch";
    hash = "sha256-wfHVCinz0CQ6O7Uy9th64588RHp5+9FXbQClqdE2tCc=";
  };

  postPatch = ''
    # fix: error TS6133: 'KeyboardIcon' is declared but its value is never read.
    substituteInPlace src/components/settings/mouse.tsx \
      --replace-fail ", KeyboardIcon" ""

    # patch cargo dependency
    echo "patching tao-0.34.5 with https://github.com/tauri-apps/tao/pull/1204"
    pushd $cargoDepsCopy/source-registry-0/tao-0.34.5
    patch -p1 <${finalAttrs.patch-tao}
    popd
  '';

  nativeBuildInputs = [
    # Pull in our main hook
    cargo-tauri.hook

    # Setup npm
    nodejs
    npmHooks.npmConfigHook

    # Make sure we can find our libraries
    pkg-config

    # fix: GStreamer element appsink not found. Please install it.
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    # gst_all_1.gst-plugins-bad
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

  buildInputs = (lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking # Most Tauri apps need networking
    openssl
    webkitgtk_4_1
  ]) ++ [
    # fix: The system library `xtst` required by crate `x11` was not found.
    libxtst
    # fix: Can't detect any appindicator library
    libappindicator
  ];

  # TODO why is this not working compared to
  # gappsWrapperArgs+=(...) in preFixup
  /*
  gappsWrapperArgs = [
    "--prefix" "LD_LIBRARY_PATH" ":" (lib.makeLibraryPath [ libappindicator ])
  ];
  */

  preFixup = ''
    gappsWrapperArgs+=(
      # fix: libappindicator3.so: cannot open shared object file: No such file or directory
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libappindicator ]}
    )
  '';

  # Set our Tauri source directory
  cargoRoot = "src-tauri";
  # And make sure we build there too
  buildAndTestSubdir = finalAttrs.cargoRoot;

  meta = {
    description = "tool to visualize your keystrokes and mouse actions";
    homepage = "https://github.com/mulaRahul/keyviz";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "keyviz";
    platforms = lib.platforms.all;
  };
})
