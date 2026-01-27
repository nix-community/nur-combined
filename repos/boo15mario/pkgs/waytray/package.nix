{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, gtk4
, gtk4-layer-shell
, gst_all_1
, wrapGAppsHook4
}:

rustPlatform.buildRustPackage rec {
  pname = "waytray";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "destructatron";
    repo = "waytray";
    rev = "ccd6ac471754ff951af128e5df4033702cf2cbe1";
    hash = "sha256-qf6t5Y9gA9uF6Ku/J6zdsJ0oohX5xCjdyZiPlJPPln0=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    gtk4-layer-shell
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  meta = with lib; {
    description = "Accessible, compositor-agnostic system tray for Linux";
    homepage = "https://github.com/destructatron/waytray";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}