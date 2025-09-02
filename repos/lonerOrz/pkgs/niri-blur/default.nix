{
  lib,
  dbus,
  eudev,
  fetchFromGitHub,
  installShellFiles,
  libdisplay-info,
  libglvnd,
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
}:
let
  raw-version = "25.8.0";
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "niri-blur";
  version = "${raw-version}" + "-feat-blur";

  src = fetchFromGitHub {
    owner = "visualglitch91";
    repo = "niri";
    rev = "feat/blur";
    hash = "sha256-1XIhLlAc/x9K6LXRK8yMD8G3RiHPOiVRHmWNgIFGVi0=";
  };

  cargoHash = "sha256-lR0emU2sOnlncN00z6DwDIE2ljI+D2xoKqG3rS45xG0=";

  outputs = [
    "out"
    "doc"
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
    libdisplay-info
    libglvnd # 用于 libEGL
    libinput
    libxkbcommon
    libgbm
    pango
    seatd
    wayland # 用于 libwayland-client
  ]
  ++ lib.optional (withDbus || withScreencastSupport || withSystemd) dbus
  ++ lib.optional withScreencastSupport pipewire
  ++ lib.optional withSystemd systemd # 包含 libudev
  ++ lib.optional (!withSystemd) eudev; # 在不使用 systemd 时，用作替代的 libudev 实现

  buildFeatures =
    lib.optional withDbus "dbus"
    ++ lib.optional withDinit "dinit"
    ++ lib.optional withScreencastSupport "xdp-gnome-screencast"
    ++ lib.optional withSystemd "systemd";
  buildNoDefaultFeatures = true;

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
    # 强制链接 libEGL 和 libwayland-client
    # 这样在运行时可以通过 dlopen() 被发现
    RUSTFLAGS =
      (toString (
        map (arg: "-C link-arg=" + arg) [
          "-Wl,--push-state,--no-as-needed"
          "-lEGL"
          "-lwayland-client"
          "-Wl,--pop-state"
        ]
      ))
      + " -C debuginfo=line-tables-only";

    # 上游建议在没有 Git 仓库的构建环境中手动设置提交 hash
    # 参考：https://github.com/YaLTeR/niri/wiki/Packaging-niri#version-string
    NIRI_BUILD_COMMIT = "NUR";
  };

  checkFlags = [
    # These tests require the ability to access a "valid EGL Display", but that won't work
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
