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
    rev = "95afa163a60167cd97bf6afa870bc117a1be3d03";
    fetchSubmodules = false;
    sha256 = "sha256-cUlTHg/F0tUpjS/uAIYKwrIRaKwuzdyFo3IiST6E7Fc=";
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
