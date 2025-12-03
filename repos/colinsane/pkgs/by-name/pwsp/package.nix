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
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pwsp";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "arabianq";
    repo = "pipewire-soundpad";
    rev = "v${finalAttrs.version}";
    hash = "sha256-L5angjuk7TTs2ZxyHc+kkvDsYH6drYKn8cU+vJV89Es=";
  };

  cargoHash = "sha256-vs2LJGiodarXXcT8LR4bTwSTr4Co+u9h2i/DGTwIUbM=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
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

  postInstall = ''
    install -Dm644 assets/pwsp-gui.desktop $out/share/applications/pwsp.desktop
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
