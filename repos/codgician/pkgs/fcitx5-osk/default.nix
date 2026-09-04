{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  openssl,
  fontconfig,
  libGL,
  libxkbcommon,
  wayland,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxcb,
  vulkan-loader,
  makeWrapper,
  nix-update-script,
  runCommand,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fcitx5-osk";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "fortime";
    repo = "fcitx5-osk";
    tag = finalAttrs.version;
    hash = "sha256-g1klvPXGWMZlxVZHEP8JPQT6P1I260vvqU4npyLP4cQ=";
  };

  cargoHash = "sha256-Zx3wPuIrvWbLsMWtCP0efq1rLolVMS94xlKaaFqgJeA=";

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    cmake
    makeWrapper
  ];

  buildInputs = [
    openssl
    fontconfig
    libGL
    libxkbcommon
    wayland
    libx11
    libxcursor
    libxi
    libxrandr
    libxcb
    vulkan-loader
  ];

  # Prefer the system OpenSSL rather than a vendored copy.
  env.OPENSSL_NO_VENDOR = "1";

  # Virtual workspace: build the on-screen keyboard, key helper, and KWin launcher.
  cargoBuildFlags = [
    "--package"
    "fcitx5-osk"
    "--package"
    "fcitx5-osk-key-helper"
    "--package"
    "fcitx5-osk-kwin-launcher"
  ];

  # No unit tests are shipped in the workspace crates.
  doCheck = false;

  # Upstream uses CMake only as an install wrapper around `cargo build --release`.
  # Replicate the install layout here so the Nix build stays offline and
  # does not depend on CMake 4.1 (required by upstream's CMakeLists.txt).
  postInstall =
    let
      graphicsLibs = lib.makeLibraryPath [
        fontconfig
        libGL
        libxkbcommon
        wayland
        libx11
        libxcursor
        libxi
        libxrandr
        libxcb
        vulkan-loader
        openssl
      ];
    in
    ''
      install -Dm644 assets/icons/fcitx5-osk.svg \
        $out/share/icons/hicolor/scalable/apps/fyi.fortime.Fcitx5Osk.svg

      install -Dm644 LICENSE -t $out/share/licenses/fcitx5-osk
      install -Dm644 LICENSE -t $out/share/licenses/fcitx5-osk-kwin-launcher

      # Default themes, layouts, and custom actions (also exposed via XDG config dirs).
      mkdir -p $out/share/fcitx5-osk $out/etc/xdg/fcitx5-osk
      cp -r pkg/share/fcitx5-osk/. $out/share/fcitx5-osk/
      cp -r pkg/share/fcitx5-osk/. $out/etc/xdg/fcitx5-osk/

      mkdir -p $out/share/fcitx5-osk/examples
      cp -r assets/layouts assets/key_sets $out/share/fcitx5-osk/examples/

      # Desktop entries and session D-Bus services (paths rewritten to $out/bin).
      install -Dm644 pkg/share/applications/fyi.fortime.Fcitx5Osk.desktop.in \
        $out/share/applications/fyi.fortime.Fcitx5Osk.desktop
      install -Dm644 pkg/share/applications/fyi.fortime.Fcitx5Osk.KwinLauncher.desktop.in \
        $out/share/applications/fyi.fortime.Fcitx5Osk.KwinLauncher.desktop
      install -Dm644 pkg/share/dbus-1/services/fyi.fortime.Fcitx5Osk.service.in \
        $out/share/dbus-1/services/fyi.fortime.Fcitx5Osk.service
      install -Dm644 pkg/share/dbus-1/services/fyi.fortime.Fcitx5Osk.KwinLauncher.service.in \
        $out/share/dbus-1/services/fyi.fortime.Fcitx5Osk.KwinLauncher.service

      substituteInPlace \
        $out/share/applications/fyi.fortime.Fcitx5Osk.desktop \
        $out/share/applications/fyi.fortime.Fcitx5Osk.KwinLauncher.desktop \
        $out/share/dbus-1/services/fyi.fortime.Fcitx5Osk.service \
        $out/share/dbus-1/services/fyi.fortime.Fcitx5Osk.KwinLauncher.service \
        --replace-fail '@INSTALL_BIN_DIR@' "$out/bin"

      # System D-Bus policy and systemd unit for the key helper.
      install -Dm644 pkg/share/dbus-1/system.d/fyi.fortime.Fcitx5OskKeyHelper.conf \
        $out/share/dbus-1/system.d/fyi.fortime.Fcitx5OskKeyHelper.conf

      install -Dm644 pkg/lib/systemd/system/fcitx5-osk-key-helper.service.in \
        $out/lib/systemd/system/fcitx5-osk-key-helper.service
      substituteInPlace $out/lib/systemd/system/fcitx5-osk-key-helper.service \
        --replace-fail '@INSTALL_BIN_DIR@' "$out/bin"

      # iced/wgpu and wayland-sys dlopen graphics libraries at runtime.
      wrapProgram $out/bin/fcitx5-osk \
        --prefix LD_LIBRARY_PATH : "${graphicsLibs}" \
        --prefix XDG_CONFIG_DIRS : "$out/etc/xdg"
    '';

  passthru = {
    updateScript = nix-update-script { };

    tests.cli-help = runCommand "fcitx5-osk-cli-help" { } ''
      ${lib.getExe finalAttrs.finalPackage} --help | grep -Fq 'Start a virtual keyboard'
      ${lib.getExe finalAttrs.finalPackage} --version | grep -Fq '${finalAttrs.version}'
      ${finalAttrs.finalPackage}/bin/fcitx5-osk-key-helper --help | grep -Fq 'config'
      ${finalAttrs.finalPackage}/bin/fcitx5-osk-kwin-launcher --help | grep -Fq 'dbus-server'
      test -f ${finalAttrs.finalPackage}/share/applications/fyi.fortime.Fcitx5Osk.desktop
      test -f ${finalAttrs.finalPackage}/share/dbus-1/system.d/fyi.fortime.Fcitx5OskKeyHelper.conf
      test -f ${finalAttrs.finalPackage}/lib/systemd/system/fcitx5-osk-key-helper.service
      touch "$out"
    '';
  };

  meta = {
    description = "On-screen keyboard designed to work with Fcitx5, especially on KDE Plasma Wayland";
    homepage = "https://github.com/fortime/fcitx5-osk";
    changelog = "https://github.com/fortime/fcitx5-osk/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "fcitx5-osk";
  };
})
