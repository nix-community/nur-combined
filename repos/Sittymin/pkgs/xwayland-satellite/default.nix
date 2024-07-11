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
    rev = "3140b7c83e0eade33abd94b1adac6a368db735f9";
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
