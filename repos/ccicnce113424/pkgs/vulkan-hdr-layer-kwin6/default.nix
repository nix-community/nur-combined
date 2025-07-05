{
  sources,
  version,
  lib,
  stdenv,
  cmake,
  libX11,
  meson,
  ninja,
  pkg-config,
  unstableGitUpdater,
  vulkan-headers,
  vulkan-loader,
  wayland-scanner,
  wayland,
}:

stdenv.mkDerivation {
  inherit (sources) pname src;
  inherit version;

  depsBuildBuild = [ pkg-config ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
    wayland-scanner
  ];

  buildInputs = [
    vulkan-headers
    vulkan-loader
    libX11
    wayland
  ];

  strictDeps = true;

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Vulkan Wayland HDR WSI Layer (Xaver Hugl's fork for KWin 6)";
    homepage = "https://github.com/Zamundaaa/VK_hdr_layer";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      # This package has been removed from nixpkgs, but it is still needed by NVIDIA GPU users.
      # d4rk
      ccicnce113424
    ];
  };
}
