{
  lib,
  rustPlatform,
  rustc,
  fetchFromGitHub,
  fetchNpmDeps,
  cargo-tauri,
  nodejs,
  npmHooks,
  makeWrapper,
  pkg-config,
  cmake,
  wrapGAppsHook3,
  alsa-lib,
  dbus,
  desktop-file-utils,
  glib-networking,
  libopus,
  openssl,
  pipewire,
  systemdLibs,
  webkitgtk_4_1,
  xdg-utils,
  zenity,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vacs";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "vacs-project";
    repo = "vacs";
    tag = "vacs-client-v${finalAttrs.version}";
    hash = "sha256-QLdncUwI/es8vhr+EzyjOcQcoKfXCO5i3Cdc9LwH9Po=";
  };

  cargoHash = "sha256-svIdDSBFcBxq2XkZobTK6mWjHWv2dMvvL9FldOpeHho=";

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    src = "${finalAttrs.src}/vacs-client";
    hash = "sha256-vsRIOvQM6R8CjL//p21s9S6mgewrNGcpRE3nkRNVRnU=";
  };
  npmRoot = "vacs-client";

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    npmHooks.npmConfigHook
    pkg-config
    cmake # vendored static SDL3 (joystick input)
    rustPlatform.bindgenHook # pipewire-sys, libspa-sys
    wrapGAppsHook3
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    dbus
    glib-networking
    libopus
    openssl
    pipewire
    systemdLibs # libudev for SDL joystick hotplug
    webkitgtk_4_1
  ];

  # cmake is only needed by the sdl3-sys build script, not as the package's build system.
  dontUseCmakeConfigure = true;

  buildAndTestSubdir = "vacs-client";

  tauriBuildFlags = [
    "--config"
    # Upstream signs updater artifacts in CI; without TAURI_SIGNING_PRIVATE_KEY the bundler aborts.
    ''{"bundle":{"createUpdaterArtifacts":false}}''
  ];

  # aws-lc-sys must build its vendored copy, matching upstream release builds.
  env.AWS_LC_SYS_USE_SYSTEM = "0";

  # Upstream CI runs the test suite; it is not needed to produce the client.
  doCheck = false;

  dontWrapGApps = true;

  # deep-link registration runs update-desktop-database + xdg-mime to claim vacs://
  postFixup = ''
    mv $out/bin/vacs-client $out/lib/vacs/vacs-client
    makeWrapper $out/lib/vacs/vacs-client $out/bin/vacs-client \
      "''${gappsWrapperArgs[@]}" \
      --suffix PATH : ${
        lib.makeBinPath [
          desktop-file-utils
          xdg-utils
          zenity
        ]
      }
  '';

  meta = {
    description = "Ground-to-ground voice communication system for VATSIM";
    homepage = "https://vacs.network";
    changelog = "https://github.com/vacs-project/vacs/releases/tag/vacs-client-v${finalAttrs.version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "vacs-client";
    # Workspace declares rust-version = "1.95.0".
    broken = lib.versionOlder rustc.version "1.95.0";
  };
})
