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
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "vacs-project";
    repo = "vacs";
    tag = "vacs-client-v${finalAttrs.version}";
    hash = "sha256-CBUiVpsVRDTKyZ+7ORzjEnFfFWp58RUTdCUt9S/k5DY=";
  };

  cargoHash = "sha256-CjVDFqwFU1z4yDIcNMhq+XXY+L4C+y/2z704OtKj/Xw=";

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    src = "${finalAttrs.src}/vacs-client";
    hash = "sha256-3JfQ+eeudQ0ZsnaMHnL0aGy0eqJ5daakM6iw++4bPKo=";
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
  # Upstream renamed the binary to `vacs` and ships a deb-only `vacs-client` shim that
  # execs /usr/bin/vacs; replace it with a link to the wrapped binary.
  postFixup = ''
    rm $out/bin/vacs-client
    mv $out/bin/vacs $out/lib/vacs/vacs
    makeWrapper $out/lib/vacs/vacs $out/bin/vacs \
      "''${gappsWrapperArgs[@]}" \
      --suffix PATH : ${
        lib.makeBinPath [
          desktop-file-utils
          xdg-utils
          zenity
        ]
      }
    ln -s vacs $out/bin/vacs-client
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
    mainProgram = "vacs";
    # Workspace declares rust-version = "1.95.0".
    broken = lib.versionOlder rustc.version "1.95.0";
  };
})
