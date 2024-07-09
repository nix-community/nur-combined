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
    # 2024.7.5 commit
    rev = "d32eae139dc7d2bdb288a308e76fc98a57a4e66b";
    fetchSubmodules = false;
    sha256 = "sha256-NcvFk8u43Q/XiuHzO1yQX9veXy6frRBJZhDHz3ESUX0=";
  });

  cargoSha256 = "sha256-xP3qGSaYw+cNnnsjCLwP3RKBpgW+wnIzid2rUepgSW8=";

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
