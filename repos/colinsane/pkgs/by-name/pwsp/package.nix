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
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "arabianq";
    repo = "pipewire-soundpad";
    rev = "v${finalAttrs.version}";
    hash = "sha256-sxd8SxAGPsAIoEMHLSfOSy8sLFN9qby+6cgqTU/zZXQ=";
  };

  cargoHash = "sha256-SWEvQjqmGlt9IuY6KKT3En453fOsneNvNfJtMTdwWmc=";

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

  meta = with lib; {
    description = "Soundpad for linux that works via pipewire";
    homepage = "https://github.com/arabianq/pipewire-soundpad";
    license = licenses.mit;
    maintainers = with maintainers; [ colinsane ];
  };
})
