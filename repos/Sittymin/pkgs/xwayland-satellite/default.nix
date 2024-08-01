{ lib
, rustPlatform
, fetchFromGitHub
, xcb-util-cursor
, pkg-config
}:

rustPlatform.buildRustPackage {
  pname = "xwayland-satellite";
  version = "unstable";
  src = fetchFromGitHub ({
    owner = "Supreeeme";
    repo = "xwayland-satellite";
    # newer commit
    rev = "8892570093948de16a50e06b1a7d6890405de7a1";
    fetchSubmodules = false;
    sha256 = "sha256-zk62B0tIf2SRNCeQnXxatq2gvjtaJ8xp3Hp9RB43xs0=";
  });

  cargoHash = "sha256-8SnFLRPUjQzEjr6yIY3p7YSflFONhaS9ss70ykBoTKg=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    pkg-config
  ];

  buildInputs = [
    xcb-util-cursor
  ];

  # RUSTFLAGS = "-L${xcb-util-cursor}/lib";
  PKG_CONFIG_PATH = "${xcb-util-cursor}/lib/pkgconfig";
  checkPhase = ''
    export XDG_RUNTIME_DIR=$(mktemp -d)
  '';

  meta = with lib; {
    description = "Xwayland outside your Wayland ";
    homepage = "https://github.com/Supreeeme/xwayland-satellite";
    license = licenses.mpl20;
    platforms = platforms.linux;
  };
}
