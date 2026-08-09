{
  lib,
  rustPlatform,
  pkg-config,
  udev,
  alsa-lib,
  vulkan-loader,
  xorg,
  wayland,
  libxkbcommon,
}:

rustPlatform.buildRustPackage {
  pname = "hanga";
  version = "0.1.0";

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    udev
    alsa-lib
    vulkan-loader
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    wayland
    libxkbcommon
  ];

  env.LD_LIBRARY_PATH = lib.makeLibraryPath [
    vulkan-loader
    wayland
    libxkbcommon
    alsa-lib
    udev
  ];

  meta = {
    description = "Hanga: Minecraft + Luanti + Teardown + GTA at the same time";
    homepage = "https://example.com";
    license = lib.licenses.mit;
    mainProgram = "hanga";
  };
}
