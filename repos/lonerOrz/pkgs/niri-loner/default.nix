{
  lib,
  libGL,
  cairo,
  dbus,
  eudev,
  fetchFromGitHub,
  installShellFiles,
  libdisplay-info,
  libinput,
  libxkbcommon,
  libgbm,
  pango,
  pipewire,
  pkg-config,
  rustPlatform,
  seatd,
  stdenv,
  systemd,
  wayland,
  withDbus ? true,
  withDinit ? false,
  withScreencastSupport ? true,
  withSystemd ? true,
  withLto ? false,
  withNative ? false,
}:
let
  raw-version = "25.8.0";
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "niri-blur";
  version = "${raw-version}" + "-feat-blur";

  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "niri";
    rev = "342aaf7d18897d8836ebe3ff87c5e2dcaf5b980f";
    hash = "sha256-oL+2ErXaSsCCuIs4xWRqTZSQ6+zs8AEpCjyb+TnB2tg=";
  };

  cargoHash = "sha256-Me8woNt30B77K3NPnEaB7YoT+2o64AiiYBhGzHfSUNM=";

  outputs = [
    "out"
    "doc"
  ];

  patches = [
    # Replace the tiled window implementation with a true blur method
    # ./fix-blur.patch
  ];

  postPatch = ''
    patchShebangs resources/niri-session
    substituteInPlace resources/niri.service \
      --replace-fail '/usr/bin' "$out/bin"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    cairo
    dbus
    libGL
    libdisplay-info
    libinput
    seatd
    libxkbcommon
    libgbm
    pango
    wayland
  ]
  ++ lib.optional (withDbus || withScreencastSupport || withSystemd) dbus
  ++ lib.optional withScreencastSupport pipewire
  ++ lib.optional withSystemd systemd # includes libudev
  ++ lib.optional (!withSystemd) eudev; # fallback libudev implementation if not using systemd

  buildFeatures =
    lib.optional withDbus "dbus"
    ++ lib.optional withDinit "dinit"
    ++ lib.optional withScreencastSupport "xdp-gnome-screencast"
    ++ lib.optional withSystemd "systemd";
  buildNoDefaultFeatures = true;

  # Ever since this commit:
  # https://github.com/YaLTeR/niri/commit/771ea1e81557ffe7af9cbdbec161601575b64d81
  # niri now runs an actual instance of the real compositor (with a mock backend) during tests
  # which creates a real socket file in the runtime directory.
  # This is fine for our build; we just need to ensure a directory exists for it to write to.
  preCheck = ''
    export XDG_RUNTIME_DIR="$(mktemp -d)"
  '';

  postInstall = ''
    install -Dm0644 README.md resources/default-config.kdl -t $doc/share/doc/niri
    mv docs/wiki $doc/share/doc/niri/wiki

    install -Dm0644 resources/niri.desktop -t $out/share/wayland-sessions
  ''
  + lib.optionalString withDbus ''
    install -Dm0644 resources/niri-portals.conf -t $out/share/xdg-desktop-portal
  ''
  + lib.optionalString (withSystemd || withDinit) ''
    install -Dm0755 resources/niri-session -t $out/bin
  ''
  + lib.optionalString withSystemd ''
    install -Dm0644 resources/niri{-shutdown.target,.service} -t $out/lib/systemd/user
  ''
  + lib.optionalString withDinit ''
    install -Dm0644 resources/dinit/niri{-shutdown,} -t $out/lib/dinit.d/user
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd $pname \
      --bash <($out/bin/niri completions bash) \
      --fish <($out/bin/niri completions fish) \
      --zsh <($out/bin/niri completions zsh)
  '';

  env = {
    # Force link libEGL and libwayland-client
    # so that they can be discovered via dlopen() at runtime
    RUSTFLAGS =
      (toString (
        map (arg: "-C link-arg=" + arg) [
          "-Wl,--push-state,--no-as-needed"
          "-lEGL"
          "-lwayland-client"
          "-Wl,--pop-state"
        ]
      ))
      + " -C debuginfo=line-tables-only"
      + lib.optionalString withNative " -C target-cpu=native"
      + lib.optionalString withLto " -C lto=thin -C opt-level=3";

    # Upstream recommends manually setting the commit hash in build environments without a Git repository
    # Reference: https://github.com/YaLTeR/niri/wiki/Packaging-niri#version-string
    NIRI_BUILD_COMMIT = "NUR";
  };

  checkFlags = [
    # These tests require access to a "valid EGL Display", which won't work
    # inside the Nix sandbox
    "--skip=::egl"
  ];

  passthru.providedSessions = [ "niri" ];
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Scrollable-tiling Wayland compositor";
    homepage = "https://github.com/YaLTeR/niri";
    changelog = "https://github.com/YaLTeR/niri/releases/tag/v${raw-version}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "niri";
  };
})
