{
  fetchFromGitHub,
  lib,
  pkg-config,
  rustPlatform,
  wayland,
}:
rustPlatform.buildRustPackage rec {
  pname = "deskbrid";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "coe0718";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-VKF/2mqRUxP828JZaPfez1YDTl60M1Ta6gE3Gprh/BU=";
  };

  cargoHash = "sha256-Xd7tLynUKzwvI3aITlXN+D7OhpoCjGa221ALTPQ4Q7o=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    wayland
  ];

  # Tests require a live session bus / compositor.
  doCheck = false;

  postInstall = ''
    install -Dm644 deploy/deskbrid.service $out/share/systemd/user/deskbrid.service
    substituteInPlace $out/share/systemd/user/deskbrid.service \
      --replace-fail /usr/local/bin/deskbrid $out/bin/deskbrid
    install -Dm644 deploy/org.deskbrid.policy $out/share/polkit-1/actions/org.deskbrid.policy
  '';

  meta = with lib; {
    description = "Linux desktop HAL for AI agents — one daemon, one socket, every desktop action";
    longDescription = ''
      Deskbrid auto-detects the desktop environment (GNOME, Hyprland, KDE,
      COSMIC, Sway, Niri, Wayfire, Labwc, X11) and exposes window, input,
      clipboard, screenshot and system control over a JSON Unix socket, a CLI
      and an MCP server.

      Compositor helper tools (hyprctl, grim, wl-clipboard, ydotool, spectacle,
      xdotool, ...) are resolved from PATH at runtime; install only the ones
      your desktop needs. See docs/DEPENDENCIES.md upstream.
    '';
    homepage = "https://github.com/coe0718/deskbrid";
    changelog = "https://github.com/coe0718/deskbrid/releases/tag/v${version}";
    license = licenses.mit;
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ fromSource ];
    mainProgram = pname;
  };
}
