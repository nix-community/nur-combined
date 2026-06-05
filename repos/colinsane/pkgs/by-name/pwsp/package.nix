{
  alsa-lib,
  fetchFromGitHub,
  lib,
  libglvnd,
  libxkbcommon,
  nix-update-script,
  pipewire,
  pkg-config,
  rustPlatform,
  vulkan-loader,
  wayland,
  copyDesktopItems,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pwsp";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "arabianq";
    repo = "pipewire-soundpad";
    rev = "v${finalAttrs.version}";
    hash = "sha256-iJYSM2bgdBMn4uQ9NQR8K41xVKD8zR15PksrQk2P/pY=";
  };

  cargoHash = "sha256-8Lwj1uxtLh86uv0i7h6NpcK1DUSSiof312OV7mrs8r4=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    pipewire
    # dlopen'd dependencies:
    libglvnd
    libxkbcommon
    vulkan-loader
    wayland
  ];

  desktopItems = [
    "assets/pwsp-gui.desktop"
  ];

  postInstall = ''
    install -Dm644 assets/icon.png $out/share/icons/hicolor/256x256/apps/pwsp.png
    install -Dm644 assets/pwsp-daemon.service $out/lib/systemd/user/pwsp-daemon.service
  '';

  # Force linking to libEGL, which is always dlopen()ed, and to
  # libwayland-client & libxkbcommon, which is dlopen()ed based on the
  # winit backend.
  # from <repo:nixos/nixpkgs:pkgs/by-name/uk/ukmm/package.nix>
  NIX_LDFLAGS = [
    "--push-state"
    "--no-as-needed"
    "-lEGL"
    "-lvulkan"
    "-lwayland-client"
    "-lxkbcommon"
    "--pop-state"
  ];

  passthru.updateScript = nix-update-script { };
  passthru.updateWithSuper = false;  #< 2026-05-11: i don't actively use this

  meta = {
    description = "Soundpad for linux that works via pipewire";
    homepage = "https://github.com/arabianq/pipewire-soundpad";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
