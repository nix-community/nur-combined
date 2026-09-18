{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  seatd,
  mesa,
  libdisplay-info,
  libxkbcommon,
  libinput,
  libgbm,
  libGL,
  wayland,
  wayland-protocols,
}:
rustPlatform.buildRustPackage {
  pname = "driftwm";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "malbiruk";
    repo = "driftwm";
    tag = "v0.19.0";
    hash = "sha256-c/FGLGvP/7M+n41j85IA5OzqKBzzQ532eT7r61HCJJs=";
  };

  cargoHash = "sha256-rtSccFKbikMyeP1lT3Z1921/aKkws27apps2nZ7r6tE=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    seatd
    mesa
    libdisplay-info
    libxkbcommon
    libinput
    libgbm
    wayland
    wayland-protocols
  ];

  doCheck = false;

  postFixup = ''
      patchelf $out/bin/driftwm --add-rpath "${lib.makeLibraryPath [
        wayland
        libxkbcommon
        libGL
      ]}"
  '';

  postInstall = ''
      install -Dm755 resources/driftwm-session $out/bin/driftwm-session
      install -Dm644 resources/driftwm.desktop $out/share/wayland-sessions/driftwm.desktop
      install -Dm644 resources/driftwm-portals.conf $out/share/xdg-desktop-portal/driftwm-portals.conf
      install -Dm644 resources/driftwm.service $out/lib/systemd/user/driftwm.service
      install -Dm644 resources/driftwm-shutdown.target $out/lib/systemd/user/driftwm-shutdown.target
      install -Dm644 config.reference.toml $out/etc/driftwm/config.reference.toml
      for f in extras/wallpapers/*.glsl; do
        install -Dm644 "$f" "$out/share/driftwm/wallpapers/$(basename "$f")"
      done
  '';

  passthru.providedSessions = [ "driftwm" ];
  passthru.update-script = nix-update-script { };
  
  meta = {
    description = "A trackpad-first infinite canvas Wayland compositor.";
    license = lib.licenses.gpl3;
    homepage = "https://github.com/malbiruk/driftwm";
    mainProgram = "driftwm";
  };
}
