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
    rev = "3e6f892d20d918479e67d1e6c90c4be824a9d4ab";
    fetchSubmodules = false;
    sha256 = "sha256-W1UUok7DPi4IXCYtc273FbVH1ifuCIcl+oO6CDqt8Dk=";
  });

  cargoHash = "sha256-Ankfl5nlS+u0vHrOfI7t110upftnoG61Mv/lQyRUTJk=";

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
